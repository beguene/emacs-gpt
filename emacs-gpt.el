;;; emacs-gpt.el --- Description -*- lexical-binding: t; -*-

;;
;; HOW-TO
;; 1. Install Emacs https://www.gnu.org/software/emacs/
;;      for MacOS `brew install emacs`
;;      Optionally but highly recommended use https://github.com/doomemacs/doomemacs
;;
;; 2. replace sk-XXX below with your OPENAI API KEY
;;
;; 3. From emacs eval this buffer (M-x eval-buffer) https://www.gnu.org/software/emacs/manual/html_node/emacs/Lisp-Eval.html
;;     this will make gpt-elisp-edit function available
;;
;; 4. Call gpt-elisp-edit or even better bind it to a key
;;    in plain emacs: (global-set-key [f1] 'help-for-help)
;;    in doom emacs: (map! "C-' e" #'gpt-elisp-edit)
;;
;; When gpt-elisp-edit is called:
;; if a region is selected this region will be sent to the API (see https://openai.com/blog/gpt-3-edit-insert/)
;; otherwise the full buffer will be sent
;; the api response will replace the current buffer and the buffer will be saved
;;
;; WARNING 1: please be careful as the full buffer content will be sent so you should avoid using it on private data
;; WARNING 2: The code returned can be insecure and is not fully predictable


(require 'request)

(defcustom gpt-elisp-edit-api-key-getter (lambda () "sk-XXX")
  "API key for OpenAI"
  :type 'function
  :group 'gpt-elisp-edit)

(defun gpt-elisp-edit--api-call (model input instruction callback &optional temperature)
  "Call the OpenAI API with MODEL and QUERY"
  (let* ((api-key (funcall gpt-elisp-edit-api-key-getter))
         (url "https://api.openai.com/v1/edits")
         (headers `(("Content-Type" . "application/json")
                    ("Authorization" . ,(concat "Bearer " api-key))))
         (data `((model . ,model)
                 (input . ,input)
                 (instruction . ,instruction)
                 ,@(when temperature
                     (list (cons "temperature" temperature))))))
    (request
     url
     :type "POST"
     :headers headers
     :data (json-encode data)
     :parser 'json-read
     :success callback
     :error (cl-function
             (lambda (&key error-thrown &allow-other-keys)
               (message "Error: %S" error-thrown))))))

(defun gpt-elisp-edit-generic (model instruction &optional autosave)
  "Call the GPT-3 command with the selected text or the region before the cursor."
  (if (not (minibufferp))
    (setq gpt-current-buffer (current-buffer)))
  (with-current-buffer gpt-current-buffer (let ((selected-text (if (use-region-p)
                           (buffer-substring-no-properties (region-beginning) (region-end))
                         (buffer-string)))
        (initial-point (point))
        (used-region (use-region-p))
        (region-beginning-saved (if (use-region-p) (region-beginning) nil))
        (region-end-saved (if (use-region-p) (region-end) nil))
        (point-max-saved (point-max))
        (point-min-saved (point-min))
        (original-buffer (current-buffer)))
                      (cl-function (lambda (&key data &allow-other-keys)
                                   (let ((choice (aref (cdr (assoc 'choices data)) 0)))
                                     (with-current-buffer gpt-current-buffer  ; Switch to the original buffer
                                         (if used-region
                                             (delete-region region-beginning-saved region-end-saved)
                                           (delete-region point-min-saved point-max-saved))
                                         (insert (concat (cdr (assoc 'text choice))))
                                         (if autosave
                                             (save-buffer))
                                         (goto-char (point-max)))))) 0))))
      (gpt-elisp-edit--api-call model selected-text instruction

(defun gpt-elisp-edit-code (instruction)
  (interactive "sInstruction: ")
  (gpt-elisp-edit-generic "code-davinci-edit-001" instruction t))

(defun gpt-elisp-edit-text (instruction)
  (interactive "sInstruction: ")
  (gpt-elisp-edit-generic "text-davinci-edit-001" instruction t))

(defun gpt-elisp-edit (instruction)
  (interactive "sInstruction: ")
  (if (derived-mode-p 'prog-mode)
      (gpt-elisp-edit-generic "code-davinci-edit-001" instruction t)
      (gpt-elisp-edit-generic "text-davinci-edit-001" instruction t)))
