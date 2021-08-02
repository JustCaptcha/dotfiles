;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Albert Islamov"
      user-mail-address "higashi166@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;;(setq doom-theme 'doom-one)
(setq doom-theme 'doom-laserwave)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (eglot))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; international keyboard support
;; Russia
(setq default-input-method "cyrillic-jcuken")
(setq rustic-lsp-server 'rust-analyzer)

(setq-default evil-escape-key-sequence "jj")
(setq-default evil-escape-delay 0.2)

;;;;;;;;;;;;;;;;;;;;
;;; set up unicode
(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

(let ((opam-share (ignore-errors (car (process-lines "opam" "config" "var" "share")))))
  (when (and opam-share (file-directory-p opam-share))
    ;; Register Merlin
    (add-to-list 'load-path (expand-file-name "emacs/site-lisp" opam-share))
    (autoload 'merlin-mode "merlin" nil t nil)
    ;; Automatically start it in OCaml buffers
    (add-hook 'tuareg-mode-hook 'merlin-mode t)
    (add-hook 'caml-mode-hook 'merlin-mode t)
    ;; Use opam switch to lookup ocamlmerlin binary
    (setq merlin-command 'opam)))

(require 'lsp-mode)
(lsp-register-client
 (make-lsp-client :new-connection (lsp-stdio-connection "/usr/bin/reason-language-server")
                  :major-modes '(reason-mode)
                  :notification-handlers (ht ("client/registerCapability" 'ignore))
                  :priority 1
                  :server-id 'reason-ls))

;;; ron-mode.el --- Rusty Object Notation mode -*- lexical-binding: t; -*-

;; Copyright (C) 2020 Daniel Hutzley
;; This work is licensed under the terms of the BSD 2-Clause License ( https://opensource.org/licenses/BSD-2-Clause )
;; Some inspiration was drawn from Devin Schwab's RON major mode, most predominantly in the indentation function.
;; SPDX-License-Identifier: BSD-2-Clause

;; Author: Daniel Hutzley <endergeryt@gmail.com>
;; URL: https://chiselapp.com/user/Hutzdog/repository/ron-mode/home
;; Version: 1
;; Package-Requires: ((emacs "24.5.1"))
;; Keywords: languages


;;; Commentary:
;; Syntax highlights Rusty Object Notation, see https://github.com/ron-rs/ron

;;; Code:

(defvar ron-highlights nil "Highlights for Rusty Object Notation.")
(defvar ron-indent-offset 4)
(defvar ron-mode-syntax-table nil "Ron Mode Syntax Table")

(setq ron-mode-syntax-table
      (let ((synTable (make-syntax-table)))
        (modify-syntax-entry ?\/ ". 12b" synTable)
        (modify-syntax-entry ?\n "> b" synTable)
        synTable))

(setq ron-highlights
      '(; Comments
        ("//.*\\(TODO\\|FIXME\\|XXX\\|BUG\\).*" . (1 font-lock-warning-face))

                                        ; Constant face
        ("true\\|false" . font-lock-constant-face)
        ("[0-9]+"       . font-lock-constant-face)

                                        ; Function name face
        ("[A-Z]\\([a-zA-Z\\-]*\\)" . font-lock-function-name-face)

                                        ; Keyword face
        ("[a-z]\\([a-zA-Z\\-]*\\)" . font-lock-keyword-face)))

(defun ron-indent-line ()
  "Handles line indentation."
  (interactive)
  (let ((indent-col 0))
    (save-excursion
      (beginning-of-line)
      (condition-case nil
          (while t
            (backward-up-list 1)
            (when (looking-at "[[{\\(]")
              (setq indent-col (+ indent-col ron-indent-offset))))
        (error nil)))
    (save-excursion
      (back-to-indentation)
      (when (and (looking-at "[]}\\)]") (>= indent-col ron-indent-offset))
        (setq indent-col (- indent-col ron-indent-offset))))
    (indent-line-to indent-col)))


(define-derived-mode ron-mode prog-mode "ron"
  "Major mode for Rusty Object Notation"
  (setq font-lock-defaults '(ron-highlights))
  (setq tab-width ron-indent-offset)
  (setq indent-line-function #'ron-indent-line)
  (setq indent-tabs-mode nil))

(add-to-list 'auto-mode-alist '("\\.ron" . ron-mode))
(provide 'ron-mode)

;;; ron-mode.el ends here
;; (defvar elcord-client-id '"711620373120024576")
