; ----------------
; DEFAULT SETTINGS
; ----------------
(add-to-list 'default-frame-alist '(undecorated . t))
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)

(when (display-graphic-p)
  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  (tooltip-mode -1)
  (set-fringe-mode 10))
(menu-bar-mode -1)

(setq custom-theme-directory "~/.emacs.d/themes")
(load-theme 'suckless-dark t)

(column-number-mode)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(setq display-line-numbers-type 'relative)
(setq scroll-margin 0)
(setq scroll-step 1)

(defun set-custom-font ()
  (interactive)
  (set-face-attribute 'default nil :font "TX-02 18")
  (set-face-attribute 'fixed-pitch nil :font "TX-02 18")
  (set-face-attribute 'variable-pitch nil :font "TX-02 18"))
(set-custom-font)
(setq nov-variable-pitch nil) ;; use default font for nov-mode (epub)

(setq gc-cons-threshold 20000000) ;; 20MB of memory before GC (default: 0.78MB)
(setq large-file-warning-threshold 200000000) ;; 200MB is a large-ish file (default: 10MB) 
(setq native-comp-async-report-warnings-errors nil)

(setq savehist-mode 1)
(setq history-length 1000)

;; no backup files
(setq make-backup-files nil)
(setq backup-directory-alist `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))
;; auto refresh buffer when file changed 
(global-auto-revert-mode t)

(setq-default bidi-paragraph-direction 'left-to-right)
(setq sentence-end-double-space nil)

(setq vc-follow-symlinks t)

;; I know what I'm doing Emacs... trust me!
(put 'dired-find-alternate-file 'disabled nil)
(setq-default dired-listing-switches "-alh") ;; i'm human afterall

;; Ohh noooo... My PRECIOUS wooork
(setq confirm-kill-emacs 'y-or-n-p)

;; -----------
;; KEYBINDINGS
;; -----------
(fset 'yes-or-no-p 'y-or-n-p)
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
;; (global-set-key (kbd "TAB") 'self-insert-command)
(global-set-key (kbd "DEL") 'backward-delete-char)

;; ------------------
;; PACKAGES and MODES
;; ------------------
(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
	("melpa-stable" . "https://stable.melpa.org/packages/")
        ("melpa" . "https://melpa.org/packages/")
	("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))

(use-package evil
  :ensure t
  :init
  (setq evil-insert-state-cursor '(box))
  (setq evil-want-C-u-scroll t)
  (setq evil-want-keybinding nil)
  (setq undo-tree-history-directory-alist '(("." . ".udir")))
  ;; (setq evil-search-module 'evil-search)
  :config
  (evil-mode 1)
  (evil-set-undo-system 'undo-tree)
  (evil-set-leader 'motion (kbd "SPC"))
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)
  (define-key evil-insert-state-map (kbd "C-v") 'evil-visual-paste)
  (define-key evil-normal-state-map (kbd "-") (lambda () (interactive) (evil-ex-execute "e .")))
  (define-key evil-visual-state-map (kbd "K") 'drag-stuff-up)
  (define-key evil-visual-state-map (kbd "J") 'drag-stuff-down))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(use-package evil-numbers
  :ensure t
  :config
  (global-set-key (kbd "C-a") 'evil-numbers/inc-at-pt)
  (global-set-key (kbd "<C-x> <C-x>") 'evil-numbers/dec-at-pt))

(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))

(use-package evil-commentary
  :ensure t
  :config
  (evil-commentary-mode))

(use-package drag-stuff
  :ensure t
  :config
  (drag-stuff-mode t))

(use-package undo-tree
  :ensure t
  :config
  (global-undo-tree-mode))

(use-package projectile
  :ensure t
  :config
  (projectile-mode +1)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

;; Disable projectile if and when using TRAMP mode
(defadvice projectile-project-root (around ignore-remote first activate)
    (unless (file-remote-p default-directory) ad-do-it))

(use-package magit
  :ensure t
  :config
  (evil-define-key 'normal 'global (kbd "<leader>gg") 'magit))

;; GITHUB / GITLAB and alike
;; (use-package forge
;;   :ensure t
;;   :after magit)
   
(use-package pdf-tools
  :ensure t
  :config
  (pdf-loader-install))
  ;; (display-line-numbers 0))

;; epub
(use-package esxml
  :ensure t)
(use-package nov
  :ensure t
  :after esxml)
(add-to-list 'auto-mode-alist
	     '("\\.epub\\'" . nov-mode))

;; for debugging keys
(use-package command-log-mode
  :ensure t)

;; which-key (built-in in v30)
(which-key-mode)

;; -----------
;; PROGRAMMING
;; -----------
(editorconfig-mode 1)

(use-package slime
  :ensure t
  :init
  (setq inferior-lisp-program "sbcl"))

;; C-M-g
(use-package dumb-jump
  :ensure t
  :config
  (dumb-jump-mode))

;; -----------------
;; MISC IMPROVEMENTS
;; -----------------
(defun kill-other-buffers()
  "Kill all other buffers."
  (interactive)
  (mapc 'kill-buffer (delq (current-buffer) (buffer-list))))

(defun kill-dired-buffers()
  "Kill dired buffers."
  (interactive)
  (mapc (lambda (buffer)
		(when (eq 'dired-mode (buffer-local-value 'major-mode buffer))
		  (kill-buffer buffer)))
	(buffer-list)))

(defun encode-html (start end)
  "Encodes HTML entities; works great in Visual Mode (START END)."
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (goto-char (point-min))
      (replace-string "&" "&amp;")
      (goto-char (point-min))
      (replace-string "<" "&lt;")
      (goto-char (point-min))
      (replace-string ">" "&gt;"))))

(defun reload-config ()
  "Reload config."
  (interactive)
  (load-file "~/.emacs.d/config.el"))
(evil-define-key 'normal 'global (kbd "<leader>sem") #'reload-config) ; AKA source emacs;

(defun toggle-syntax-highlighting ()
  "Toggle syntax highlighting (font-lock-mode) in the current buffer"
  (interactive)
  (if font-lock-mode
      (font-lock-mode -1)
    (font-lock-mode 1)))
(evil-define-key 'normal 'global (kbd "<leader>tx") #'toggle-syntax-highlighting)
