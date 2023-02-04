# emacs-gpt

## Usage

Invoke any of the `gpt-elisp` interactive commands using `M-x` (Meta-X or Alt-X) on your system and typing out the instruction that you want the machine to resolve.

## Installation

```emacs-lisp
(use-package gpt-elisp
  :straight (gpt-elisp :type git
                       :host github
                       :repo "beguene/emacs-gpt")
  :custom
  (gpt-elisp-edit-api-key-getter (lambda () "sk-XXX")))
```

## Configuration

Before you use the package, configure your OpenAI API key by setting the `gpt-elisp-edit-api-key-getter`:

``` emacs-lisp
(setq gpt-elisp-edit-api-key-getter (lambda () "sk-XXX"))
```

### Using password-store to retrieve your OpenAI key

Instead of specifying your API key in source or loading it from another file, you can configure auth-source to use [password store](https://www.passwordstore.org/) as a backend.

Non straight.el users, can enable auth-source through the following call:

```emacs-lisp
(auth-source-pass-enable)
```

Straight.el users, can load and configuration the *auth-source* package as follows:

```emacs-lisp
(use-package auth-source
  :straight (:type built-in)

  :config
  (auth-source-pass-enable))
```


After loading auth-source, you can define the `gpt-elisp-edit-api-key-getter` custom variable to retrieve the password from your password store:

```emacs-lisp
(customize-set-variable
  'gpt-elisp-edit-api-key-getter
  (lambda ()
    (auth-source-pass-get 'secret "openai.com/user-handle/api-key")))
```

or again, when using straight.el:

```emacs-lisp
(use-package gpt-elisp
  :straight (aide :type git
                  :host github
                  :repo "beguene/emacs-gpt")
  :custom
  (gpt-elisp-edit-api-key-getter (lambda ()
                                   (auth-source-pass-get 'secret "openai.com/user-handle/api-key"))))
```

