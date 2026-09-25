;;; .emacs --- initialization file.  -*- lexical-binding: t; -*-
;;; Commentary:
;;; _____  _     __    _      _      _
;;;  | |  \ \_/ / /`_ \ \  / | |\ | | |\ |
;;;  |_|  /_/ \ \_\_/  \_\/  |_| \| |_| \|
;;;
;;; [ @author TxGVNN ]

;;; Code:
(when (version< emacs-version "29")
  (error "Requires GNU Emacs 29 or newer, but you're running %s" emacs-version))

(setq gc-cons-threshold most-positive-fixnum) ;; enable gcmh
(setq read-process-output-max (* 1024 1024)) ;; 1mb
;; doom-emacs:docs/faq.org#unset-file-name-handler-alist-temporarily
(defvar doom--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist doom--file-name-handler-alist)))
(defvar emacs-config-version "20260925.0913")
(defvar hidden-minor-modes '(whitespace-mode))

(require 'package)
(setq package-archives
      '(("me" . "https://txgvnn.github.io/giaelpa/")
        ("melpa" . "https://melpa.org/packages/")
        ("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/"))
      package-archive-priorities '(("me" . 9)))

;; BOOTSTRAP `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(use-package gcmh
  :ensure t
  :init (gcmh-mode)
  :config
  (setq gcmh-idle-delay 'auto)
  (add-to-list 'hidden-minor-modes 'gcmh-mode))

;;; COMPLETION SYSTEM: vertico, orderless, marginalia, consult, embark
(use-package vertico
  :ensure t
  :init (vertico-mode)
  :config
  (setq vertico-cycle t)
  (delete ".git/" completion-ignored-extensions)
  (add-hook 'minibuffer-setup-hook #'vertico-repeat-save)
  (advice-add #'vertico--format-candidate :around
              (lambda (orig cand prefix suffix index _start)
                (setq cand (funcall orig cand prefix suffix index _start))
                (concat
                 (if (= vertico--index index)
                     (propertize "»" 'face 'vertico-current) " ") cand)))
  :bind ("C-x C-r" . vertico-repeat)
  (:map vertico-map
        ("<prior>" . vertico-scroll-down)
        ("<next>" . vertico-scroll-up)))
(use-package vertico-directory
  :after vertico
  :ensure nil
  :bind (:map vertico-map ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package marginalia
  :ensure t :defer t
  :hook (after-init . marginalia-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((command (styles . (orderless+initialism)))
     (symbol (styles . (orderless+initialism)))
     (variable (styles . (orderless+initialism)))
     (file (styles . (basic partial-completion)))
     (minibuffer (styles . (orderless-initialism)))))
  :config
  (orderless-define-completion-style orderless+initialism
    (orderless-matching-styles '(orderless-initialism
                                 orderless-literal
                                 orderless-regexp)))
  :hook
  (shell-mode . (lambda () (setq-local completion-styles '(substring orderless)))))

(use-package consult
  :ensure t :defer t
  :bind
  ("C-x b" . consult-buffer)
  ("M-g g" . consult-goto-line)
  ("M-g M-g" . consult-goto-line)
  ("M-g i" . consult-imenu)
  ("M-g o" . consult-outline)
  ("M-g m" . consult-mark)
  ("M-g k" . consult-global-mark)
  ("M-g e" . consult-flymake)
  ("M-s m" . consult-man)
  ("M-s w" . consult-line)
  ("M-s g" . consult-grep)
  ("M-s r" . consult-ripgrep)
  ("M-s F" . consult-find)
  ("M-s u" . consult-focus-lines)
  ("C-x / k" . consult-keep-lines)
  ("M-X" . consult-mode-command)
  ("C-x B" . consult-buffer)
  (:map minibuffer-local-map ("M-r" . consult-history))
  :init
  ;; @FIXME: Disable `consult-completion-in-region' buggy in (e)shell-mode (tramp), minibuffer (compile command)
  ;; (setq completion-in-region-function
  ;;       (lambda (&rest args)
  ;;         (apply (if (and (fboundp 'vertico-mode) vertico-mode)
  ;;                    #'consult-completion-in-region
  ;;                  #'completion--in-region) args)))
  (advice-add #'multi-occur :override #'consult-multi-occur)
  (advice-add #'register-preview :override #'consult-register-window)
  (setq xref-show-definitions-function #'consult-xref
        xref-show-xrefs-function #'consult-xref)
  :config
  (setq consult-project-function nil
        consult-grep-args
        '("grep" (consult--grep-exclude-args)
          "--null --line-buffered --color=never --ignore-case\
     --with-filename --line-number -I -r -R"))
  (setq register-preview-delay 0
        register-preview-function #'consult-register-format
        consult-preview-key "C-l")
  (setf (alist-get 'slime-repl-mode consult-mode-histories)
        'slime-repl-input-history))

(use-package embark
  :ensure t :defer t
  :bind ("C-c /" . embark-act)
  (:map minibuffer-local-map ("M-o" . embark-act))
  (:map embark-general-map ("/" . embark-chroot))
  (:map embark-region-map ("M-&" . async-shell-from-region))
  (:map embark-file-map
        ("s" . embark-run-eat)
        ("S" . embark-run-shell)
        ("t" . embark-run-term)
        ("v" .  magit-status-setup-buffer)
        ("M-+" . make-directory-and-go)
        ("x" . consult-file-externally))
  :config
  (setq embark-indicators '(embark-minimal-indicator))
  ;; as chroot
  (defun embark-chroot (dir &optional prefix)
    "Run CMD in directory DIR."
    (interactive "DIn directory:\nP")
    (let ((default-directory (replace-regexp-in-string "[^/]*$" "" dir))
          (embark-quit-after-action t)
          (action (embark--prompt
                   (mapcar #'funcall embark-indicators)
                   (embark--action-keymap 'file nil) `(,(list :type 'file :target `,dir)))))
      (command-execute action)))
  ;; project become
  (defun embark-become-project (&optional _target)
    (interactive "s") ; prompt for _target and ignore it
    (embark--quit-and-run
     (lambda ()
       (let ((use-dialog-box nil)
             (this-command 'project-switch-project))
         (command-execute this-command)))))
  (define-key embark-general-map (kbd "p") #'embark-become-project)
  ;; region
  (add-to-list 'embark-target-injection-hooks
               '(async-shell-from-region embark--allow-edit))
  ;; terminal
  (defun embark-run-term(&optional dir)
    "Create or visit a ansi-term buffer."
    (interactive "D")
    (let ((default-directory (if dir (file-name-directory dir) default-directory)))
      (crux-visit-term-buffer)))
  (defun embark-run-shell(&optional dir)
    "Create or visit a shell buffer."
    (interactive "D")
    (let ((default-directory (if dir (file-name-directory dir) default-directory)))
      (crux-visit-shell-buffer)))
  (defun embark-run-eat(&optional dir)
    "Create or visit a eat buffer."
    (interactive "D")
    (let ((default-directory (if dir (file-name-directory dir) default-directory)))
      (crux-visit-eat-buffer)))
  (defun make-directory-and-go(dir)
    (interactive "D")
    (make-directory dir)
    (find-file dir)))
(use-package embark-consult
  :ensure t :defer t
  :init
  (with-eval-after-load 'consult
    (with-eval-after-load 'embark
      (require 'embark-consult))))

(use-package transient :defer t
  :custom
  (transient-save-history nil)
  :config
  (defun ~eat-sudo ()
    (interactive)
    (let ((default-directory "/sudo::~/"))
      (eat-hist "*sudo*")))
  (transient-define-prefix ~fast-and-furious()
    "Some fast functions to run"
    ["Actions"
     ("s" "eat" eat-hist)
     ("S" "eat-sudo" ~eat-sudo)]))

;;; VERSION CONTROL: git-gutter, magit, git-link
(use-package git-gutter
  :ensure t :defer t
  :init
  (setq git-gutter:lighter ""
        git-gutter:disabled-modes '("fundamental-mode"))
  (defun git-gutter-mode-turn-on-custom ()
    "Enable git-gutter except TRAMP."
    (when (not (file-remote-p default-directory))
      (git-gutter-mode +1)))
  :hook
  (prog-mode . git-gutter-mode-turn-on-custom)
  (magit-post-refresh . git-gutter:update-all-windows)
  :bind
  ("C-x v p" . git-gutter:previous-hunk)
  ("C-x v n" . git-gutter:next-hunk)
  ("C-x v s" . git-gutter:stage-hunk)
  ("C-x v r" . git-gutter:revert-hunk))

(use-package magit
  :ensure t :defer t
  :custom
  (magit-delete-by-moving-to-trash nil)
  (magit-branch-direct-configure nil) ;; don't show git variables in magit branch
  ;; (magit-refresh-status-buffer nil)    ;; should on TRAMP
  :config
  (add-hook 'magit-process-find-password-functions
            'magit-process-password-auth-source)
  (defun magit-find-file-at-path (project rev path)
    (let* ((default-directory project)
           (parts (split-string path "#L"))
           (file-path (car (split-string path "#")))
           (line-number (string-to-number (car (last parts)))))
      (with-current-buffer (magit-find-file rev file-path)
        (goto-line line-number))))
  (defun magit-find-file-at-path (project rev path)
    (let* ((default-directory project)
           (parts (split-string path "#L"))
           (file-path (car (split-string path "#")))
           (line-number (string-to-number (car (last parts)))))
      (with-current-buffer (magit-find-file rev file-path)
        (goto-line line-number))))
  (defun magit-link-at-point ()
    (interactive)
    (let ((dir (magit-with-toplevel (abbreviate-file-name default-directory)))
          (commit (magit-with-toplevel (magit-rev-parse "--short" "HEAD")))
          (magit-link nil))
      (if (eq major-mode 'magit-log-mode)
          (setq magit-link (format "(magit-show-commit \"%s\" nil nil \"%s\")"
                                   commit dir))
        (let ((file (magit-with-toplevel (magit-file-relative-name)))
              (line-num (line-number-at-pos)))
          (setq magit-link (format "(magit-find-file-at-path \"%s\" \"%s\" \"%s#L%s\")"
                                   dir commit file line-num))))
      (kill-new magit-link)
      (message magit-link)))
  :bind
  ("C-x v f" . magit-find-file))

(use-package git-link
  :ensure t :defer t
  :config (setq git-link-use-commit t))

(use-package magit-todos
  :ensure t :defer t
  :init
  (with-eval-after-load 'magit
    (let ((inhibit-message t))
      (magit-todos-mode)))
  :custom ;; j-T in magit-status buffer
  (magit-todos-branch-list nil)
  (magit-todos-update nil))

;;; SEARCHING
(use-package isearch :defer t
  :init
  (setq isearch-lazy-count t)
  (global-set-key (kbd "M-s s") 'isearch-forward-regexp)
  (global-set-key (kbd "M-s %") 'query-replace-regexp)
  (define-key isearch-mode-map (kbd "M-s %") 'isearch-query-replace-regexp))

(use-package isearch-mb
  :ensure t
  :init (isearch-mb-mode)
  :config
  (add-to-list 'isearch-mb--with-buffer #'isearch-yank-word)
  (define-key isearch-mb-minibuffer-map (kbd "C-w") #'isearch-yank-word)
  (define-key isearch-mb-minibuffer-map (kbd "M-s %") 'isearch-query-replace-regexp))

(use-package rg :ensure t :defer t)

(use-package engine-mode
  :ensure t :defer t
  :config
  (setq engine/browser-function 'eww-browse-url)
  (defengine nixhub "https://www.nixhub.io/search?q=%s")
  (defengine debian-package "https://packages.debian.org/search?searchon=names&keywords=%s")
  (defengine vagrant-box
    "https://app.vagrantup.com/boxes/search?provider=libvirt&q=%s&utf8=%%E2%%9C%%93")
  (defengine alpine-apk-file
    "https://pkgs.alpinelinux.org/contents?file=%s&path=&name=&branch=edge&arch=x86_64")
  (defengine ubuntu-package
    "https://packages.ubuntu.com/search?keywords=%s&searchon=names&suite=all&section=all"))
(use-package github-explorer
  :ensure t :defer t)

;;; WORKSPACE: project, envrc
(use-package project :defer t
  :ensure t
  :custom
  (project-vc-extra-root-markers '(".pc"))
  (project-switch-use-entire-map t)
  (project-compilation-buffer-name-function 'project-prefixed-buffer-name)
  (project-mode-line-face 'success)
  :bind
  (:map project-prefix-map
        ("b" . consult-project-buffer)
        ("s" . project-eat)
        ("S" . project-shell)
        ("M-x" . project-execute-extended-command)
        ("v" . magit-project-status))
  :config
  (add-to-list 'mode-line-misc-info '(:eval (project-mode-line-format)))
  (advice-add #'project-find-file :override #'project-find-file-cd)
  (defun project-find-file-cd (&optional include-all)
    "Project-find-file set default-directory is project-root"
    (interactive)
    (let* ((pr (project-current t))
           (default-directory (project-root pr))
           (dirs (list default-directory)))
      (project-find-file-in (thing-at-point 'filename) dirs pr include-all)))
  (defun project-prefixed-buffer-name-full (mode)
    (concat "*" (downcase mode) ":" default-directory "*"))
  (setq project-compilation-buffer-name-function 'project-prefixed-buffer-name-full)
  (defun project-eat ()
    "Project eat with history"
    (interactive)
    (let* ((default-directory (project-root (project-current t)))
           (project-shell-name (funcall project-compilation-buffer-name-function "eat"))
           (shell-buffer (get-buffer project-shell-name)))
      (if current-prefix-arg
          (eat-hist (generate-new-buffer-name project-shell-name)
                    project-shell-name)
        (if (get-buffer-process shell-buffer)
            (pop-to-buffer-same-window shell-buffer)
          (eat-hist project-shell-name project-shell-name)))))
  (defun project-consult-grep (&optional initial)
    "Using consult-grep(INITIAL) in project."
    (interactive)
    (consult-grep (project-root (project-current t)) initial))
  (define-key project-prefix-map (kbd "g") #'project-consult-grep)
  (define-key project-prefix-map (kbd "G") #'project-find-regexp)
  (defun project-consult-ripgrep (&optional initial)
    "Using consult-ripgrep(INITIAL) in project."
    (interactive)
    (consult-ripgrep (project-root (project-current t)) initial))
  (define-key project-prefix-map (kbd "r") #'project-consult-ripgrep)
  (define-key project-prefix-map (kbd "R") #'project-query-replace-regexp)
  ;; embark
  (defun embark-on-project()
    (interactive)
    (require 'embark nil t)
    (embark-chroot (project-root (project-current t))))
  (define-key project-prefix-map (kbd "/") #'embark-on-project))

(use-package project-tasks
  :ensure t :defer t
  :custom
  (project-tasks-separator ":")
  (project-tasks-get-tasks-files-func #'project-tasks--get-task-files-by-find)
  (project-tasks-files '(".*\.org$"))
  :init
  (with-eval-after-load 'embark
    (define-key embark-file-map (kbd "t") #'project-tasks-in-dir))
  :bind (:map project-prefix-map ("t" . project-tasks))
  :config
  (defun project-tasks--eval(task)
    "Execute a source block with name TASK."
    (save-excursion
      (org-babel-goto-named-src-block task)
      (org-babel-execute-src-block)))
  (with-eval-after-load 'marginalia
    (add-to-list 'marginalia-prompt-categories '("select task" . project-task)))
  (with-eval-after-load 'embark
    (defvar-keymap embark-project-task-actions
      :doc "Keymap for actions for project-task (when mentioned by name)."
      :parent embark-general-map
      "j" #'project-tasks-goto-task)
    (add-to-list 'embark-keymap-alist '(project-task . embark-project-task-actions))))

(use-package envrc
  :ensure t :defer t
  :config
  (defun my/ensure-current-project (fn &rest args) ;; purcell/envrc#59
    (let ((default-directory (project-root (project-current t))))
      (with-temp-buffer
        (envrc-mode 1)
        (apply fn args))))
  (advice-add 'project-compile :around #'my/ensure-current-project)
  (defun envrc--lighter ()
    "Return a colourised version of `envrc--status' for use in the mode line."
    (list " env["
          (list :propertize (symbol-name envrc--status)
                'face
                (pcase envrc--status
                  (`on 'envrc-mode-line-on-face)
                  (`error 'envrc-mode-line-error-face)
                  (`denied 'envrc-mode-line-error-face)
                  (`none 'envrc-mode-line-none-face)))
          ;; Cache this detail to avoid overhead in redisplay, e.g. when scrolling,
          ;; and don't display it at all for remote files
          (when envrc--running
            (list :propertize "*" 'face 'envrc-mode-line-running-face))
          "]"))
  (setq envrc-lighter '(:eval (envrc--lighter)))
  :hook (after-init . envrc-global-mode))

;; project-temp-root
(defvar project-temp-root "~/")
(defun project-temp-M-x (&optional prefix)
  "With PREFIX we will set `project-temp-root'."
  (interactive "P")
  (if prefix (setq project-temp-root (read-directory-name "Select dir: ")))
  (unless (fboundp 'embark-chroot) (require 'embark))
  (embark-chroot project-temp-root))
(global-set-key (kbd "C-x P") #'project-temp-M-x)

;;; DISPLAY ENHANCE
(use-package smartparens
  :ensure t :defer t
  :config (require 'smartparens-config)
  (add-hook 'multiple-cursors-mode-enabled-hook (lambda()(turn-off-smartparens-mode)))
  (add-hook 'multiple-cursors-mode-disabled-hook (lambda()(turn-on-smartparens-mode)))
  (add-to-list 'hidden-minor-modes 'smartparens-mode)
  :bind (:map smartparens-mode-map
              ("C-M-f" . 'sp-forward-sexp)
              ("C-M-b" . 'sp-backward-sexp))
  :hook ((markdown-mode prog-mode) . smartparens-mode))

(use-package rainbow-mode
  :ensure t :defer t
  :hook (prog-mode . rainbow-mode)
  :config (add-to-list 'hidden-minor-modes 'rainbow-mode))

(use-package rainbow-delimiters
  :ensure t :defer t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package volatile-highlights
  :ensure t
  :hook (after-init . volatile-highlights-mode)
  :config (add-to-list 'hidden-minor-modes 'volatile-highlights-mode))

(use-package symbol-overlay
  :ensure t :defer t
  :bind ("M-s H" . symbol-overlay-put)
  :hook (prog-mode . symbol-overlay-mode)
  :custom (symbol-overlay-priority 100)
  :config
  (set-face-attribute 'symbol-overlay-default-face nil :inherit 'bold :underline t)
  (add-to-list 'hidden-minor-modes 'symbol-overlay-mode))

(setq project-mode-line-face '(:foreground "#0ab" :weight bold ))

(use-package hl-todo
  :ensure t :defer t
  :hook (prog-mode . hl-todo-mode))

(use-package beacon
  :ensure t :defer t
  :hook (after-init . beacon-mode)
  :config (add-to-list 'hidden-minor-modes 'beacon-mode))

;;; COMPLETION CODE: corfu, tempel, eglot, dumb-jump, pcmpl-args
(use-package corfu
  :ensure t :defer t
  :custom
  (completion-cycle-threshold 3)
  (corfu-auto nil)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  (corfu-bar-width 0)
  (corfu-right-margin-width 0)
  :hook
  ((shell-mode eshell-mode comint-mode) . corfu-echo-mode)
  ((prog-mode text-mode) . corfu-mode)
  :bind
  (:map corfu-map
        ("M-m" . corfu-move-to-minibuffer)
        ("TAB" . corfu-complete-common-or-next) ;; Use TAB for cycling, default is `corfu-complete'.
        ([tab] . corfu-complete-common-or-next)
        ("S-TAB" . corfu-previous)
        ([backtab] . corfu-previous))
  :config
  (defvar-local corfu-common-old nil)
  (defun corfu-complete-common-or-next ()
    "Complete common prefix or advance to next candidate."
    (interactive)
    (when (and (= corfu--total 1)
               (not (thing-at-point 'filename)))
      (corfu--goto 1)
      (corfu-insert))
    (let* ((input (car corfu--input))
           (str (if (thing-at-point 'filename) (file-name-nondirectory input) input))
           (pt (length str))
           (common (try-completion str corfu--candidates)))
      (cond
       ((and (> pt 0)
             (stringp common)
             (not (string= str common)))
        (insert (substring common pt)))
       ((equal common corfu-common-old)
        (corfu-next)))
      (setq-local corfu-common-old common)))
  (put 'corfu-complete-common-or-next 'completion-predicate #'ignore)
  (defun corfu-enable-in-minibuffer ()
    "Enable Corfu in the minibuffer if `completion-at-point' is bound."
    (when (where-is-internal #'completion-at-point (list (current-local-map)))
      (setq-local corfu-auto nil)
      (corfu-mode 1)))
  (add-hook 'minibuffer-setup-hook #'corfu-enable-in-minibuffer)
  (defun corfu-move-to-minibuffer ()
    "Move completion to minibuffer instead of corfu."
    (interactive)
    (let ((completion-extra-properties corfu--extra)
          completion-cycle-threshold completion-cycling)
      (apply #'consult-completion-in-region completion-in-region--data))))

(use-package corfu-history
  :after corfu
  :init (corfu-history-mode)
  :config
  (with-eval-after-load 'savehist
    (add-to-list 'savehist-additional-variables 'corfu-history)))

(use-package cape
  :ensure t :defer t
  :bind ("C-c p" . cape-prefix-map)
  :config
  (defun cape-backends-add-to-corfu-mode ()
    (add-to-list 'completion-at-point-functions #'cape-file :append)
    (add-to-list 'completion-at-point-functions #'cape-dabbrev :append))
  :hook (corfu-mode . cape-backends-add-to-corfu-mode))

;; Configure Tempel
(use-package tempel
  :ensure t
  :custom
  (tempel-path "~/.gxt/emacs/templates")
  :bind (("M-+" . tempel-complete) ;; Alternative tempel-expand
         ("M-*" . tempel-insert))
  :init
  ;; Setup completion at point
  (defun tempel-setup-capf ()
    ;; Add the Tempel Capf to `completion-at-point-functions'.  `tempel-expand'
    ;; only triggers on exact matches. We add `tempel-expand' *before* the main
    ;; programming mode Capf, such that it will be tried first.
    (setq-local completion-at-point-functions
                (cons #'tempel-expand completion-at-point-functions)))
  :hook
  (prog-mode . tempel-setup-capf)
  (conf-mode . tempel-setup-capf)
  (text-mode . tempel-setup-capf))

(use-package dumb-jump
  :ensure t :defer t
  :init
  (add-hook 'eglot-managed-mode-hook (lambda () (add-hook 'xref-backend-functions 'dumb-jump-xref-activate t t)))
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

(use-package eglot :defer t
  :commands eglot-ensure
  :config
  (setq eglot-disable-on-tramp t)
  (defun eglot-ensure-remote (orig &rest args)
    "Ensure eglot on remote."
    (unless (and eglot-disable-on-tramp (file-remote-p default-directory))
      (apply orig args)))
  (advice-add 'eglot-ensure :around #'eglot-ensure-remote)
  :custom
  (eglot-report-progress nil)
  (eglot-sync-connect nil)
  :after (project flymake))

(use-package pcmpl-args :ensure t :defer 1)

;;; TOOLS
(use-package avy
  :ensure t :defer t
  :config
  (setq avy-all-windows nil
        avy-background t)
  :bind
  ("M-g a" . avy-goto-char)
  ("M-g l" . avy-goto-line))

(use-package crux
  :ensure t :defer t
  :bind
  ("M-o" . crux-switch-to-previous-buffer)
  ("C-^" . crux-top-join-line)
  ("C-a" . crux-move-beginning-of-line)
  ("C-o" . crux-smart-open-line)
  ("C-c c" . crux-create-scratch-buffer)
  ("C-c d" . crux-duplicate-current-line-or-region)
  ("C-c M-d" . crux-duplicate-and-comment-current-line-or-region)
  ("C-c D" . crux-delete-file-and-buffer)
  ("C-c r" . crux-rename-buffer-and-file)
  ("C-c s" . crux-visit-eat-buffer)
  ("C-c t" . crux-visit-term-buffer)
  ("C-c S" . crux-visit-shell-buffer)
  ("C-h RET" . crux-find-user-init-file)
  ("C-x / e" . crux-open-with)
  ("C-x 7" . crux-swap-windows)
  (:map diff-mode-map ("M-o" . crux-switch-to-previous-buffer)))

(use-package expreg
  :ensure t :defer t
  :init (define-key esc-map "@" 'expreg-expand))

(use-package move-text
  :ensure t :defer t
  :bind
  ("M-g <up>" . move-text-up)
  ("M-g <down>" . move-text-down))

(use-package vundo
  :ensure t :defer t
  :init (global-set-key (kbd "C-x u") #'vundo)
  :config (define-key vundo-mode-map (kbd "q") #'vundo-confirm))

(use-package pinentry
  :ensure t :defer t
  :config
  (require 'server)
  (setq pinentry--socket-dir server-socket-dir)
  :hook (after-init . pinentry-start))

(use-package multiple-cursors
  :ensure t :defer t
  :bind
  ("C-c e a" . mc/mark-all-like-this)
  ("C-c e n" . mc/mark-next-like-this)
  ("C-c e p" . mc/mark-previous-like-this)
  ("C-c e l" . mc/edit-lines)
  ("C-c e r" . mc/mark-all-in-region))

(use-package helpful
  :ensure t :defer t
  :init
  (global-set-key [remap describe-command] 'helpful-command)
  (global-set-key [remap describe-function] 'helpful-callable)
  (global-set-key [remap describe-key] 'helpful-key)
  (global-set-key [remap describe-macro] 'helpful-macro)
  (global-set-key [remap describe-variable] 'helpful-variable)
  (global-set-key [remap describe-symbol] 'helpful-symbol))

(use-package eev
  :ensure t :defer 1
  :config (require 'eev-load)
  (defun eepitch-get-buffer-name-line()
    (if (not (eq eepitch-buffer-name ""))
        (format "ξ:%s "eepitch-buffer-name) ""))
  (add-to-list 'mode-line-misc-info
               '(:eval (propertize (eepitch-get-buffer-name-line) 'face 'warning)))
  (defun eepitch-set-local-buffer-name(&rest _)
    "Set `eepitch-buffer-name' to local buffer name."
    (setq-local eepitch-code-tmp eepitch-code)
    (setq-default eepitch-code '(error "eepitch not set up"))
    (setq-local eepitch-code eepitch-code-tmp)
    (setq-local eepitch-buffer-name-tmp eepitch-buffer-name)
    (setq-default eepitch-buffer-name "")
    (setq-local eepitch-buffer-name eepitch-buffer-name-tmp))
  (defun eepitch-set-local-buffer-name-follow(&rest _)
    "Set `eepitch-buffer-name' to local buffer name."
    (setq-local eepitch-buffer-name (default-value 'eepitch-buffer-name)))
  (advice-add #'eepitch :after #'eepitch-set-local-buffer-name)
  (advice-add #'eepitch-buffer-create :after #'eepitch-set-local-buffer-name-follow)
  (advice-add #'eepitch-this-line :after #'eepitch-set-local-buffer-name)
  (defun eepitch-this-line-or-setup (&optional prefix)
    "Setup eepitch-buffer-name if PREFIX or eval this line."
    (interactive "P")
    (if (not prefix)
        (eepitch-this-line)
      (setq-local eepitch-buffer-name (read-buffer-to-switch "Buffer: "))
      (unless (get-buffer eepitch-buffer-name)
        (shell eepitch-buffer-name))))
  (global-set-key (kbd "<f8>") #'eepitch-this-line-or-setup)
  (global-set-key (kbd "<f9>") #'eepitch-this-line-or-setup))

(use-package so-long
  :ensure t :defer t
  :hook (after-init . global-so-long-mode))

(use-package 0x0 :ensure t :defer t)
(use-package dpaste :ensure t :defer t
  :config
  (add-to-list 'dpaste-supported-modes-alist '(markdown-mode . "md")))
(use-package gist
  :ensure t :defer t
  :config
  (defun gist-ask-for-description-maybe ()
    "Override to return the current file name."
    (file-name-nondirectory (or (buffer-file-name) (buffer-name)))))

(use-package devdocs
  :ensure t :defer t
  :bind ("M-s d" . #'devdocs-lookup))

;;; CHECKER: flymake(C-h .)
(use-package flymake
  :custom (flymake-mode-line-lighter "ƒ")
  :config
  (define-key flymake-mode-map (kbd "C-c ! l") 'flymake-show-diagnostics-buffer)
  (define-key flymake-mode-map (kbd "M-g n") #'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-g p") #'flymake-goto-prev-error)
  (remove-hook 'flymake-diagnostic-functions 'flymake-proc-legacy-flymake)
  :hook (prog-mode . flymake-mode))

;;; DIRED
(use-package dired :defer t
  :custom
  (dired-listing-switches "-alht")
  :bind
  (:map dired-mode-map ("E" . dired-ediff-files))
  :config
  (defun dired-auto-update-name (&optional suffix)
    "Auto update name with SUFFIX.ext."
    (interactive "p")
    (let ((filename (file-name-nondirectory (dired-get-file-for-visit)))
          (timestamp (format-time-string "%Y%m%dT%H%M%S")))
      (rename-file filename (concat filename "_" timestamp) t)
      (revert-buffer))))
(use-package diredfl
  :ensure t :defer t
  :init (add-hook 'dired-mode-hook 'diredfl-mode))

;;; TERM: shell, term, xclip
(setenv "PAGER" "cat")
(defun interactive-cd (dir)
  "Prompt for a DIR and cd to it."
  (interactive "Dcd ")
  (let ((inhibit-read-only t))
    (insert (concat "cd " dir)))
  (pcase major-mode
    ('shell-mode (comint-send-input))
    ('eshell-mode (eshell-send-input))
    ('term-mode (term-send-input))))

(use-package with-editor
  :ensure t :defer t
  :init
  (add-hook 'shell-mode-hook  #'with-editor-export-editor)
  (add-hook 'eshell-mode-hook #'with-editor-export-editor)
  (add-hook 'term-exec-hook   #'with-editor-export-editor)
  (add-hook 'vterm-mode-hook  #'with-editor-export-editor))

(use-package comint :defer t
  :custom
  (comint-input-ignoredups t)
  (comint-input-ring-size 1024))

(use-package shell
  :bind (:map shell-mode-map ("C-c d" . interactive-cd))
  :config
  (defun shell--save-history (&rest _)
    "Save `shell' history."
    (let ((inhibit-message t))
      (comint-write-input-ring)))
  (advice-add #'comint-add-to-input-history :after #'shell--save-history)
  (defun shell-hist(buffer-name &optional histfile)
    "Create a shell BUFFER-NAME and set `comint-input-ring-file-name' is HISTFILE."
    (let* ((shell-directory-name (locate-user-emacs-file "shell"))
           (histfile (or histfile buffer-name))
           (comint-history-file (expand-file-name
                                 (format "%s/%s.history" shell-directory-name
                                         (replace-regexp-in-string
                                          "/" "~"
                                          (format "%s.%s" (abbreviate-file-name default-directory) histfile)))))
           (comint-input-ring-file-name comint-history-file)
           (comint-input-ring (make-ring 1))
           (buff (get-buffer-create buffer-name)))
      ;; HACK: make shell-mode doesnt set comint-input-ring-file-name
      (ring-insert comint-input-ring "uname")
      (with-current-buffer (shell buff)
        (setq-local comint-input-ring-file-name comint-history-file)
        (comint-read-input-ring t)
        (set-process-sentinel (get-buffer-process (current-buffer))
                              #'shell-write-history-on-exit))
      (pop-to-buffer buff)
      buff)))

(use-package term :defer t
  :hook
  (term-mode . (lambda()
                 (let (term-escape-char) (term-set-escape-char ?\C-x))))
  :bind
  (:map term-mode-map
        ("C-c d" . interactive-cd))
  (:map term-raw-map
        ("M-x"  . execute-extended-command)
        ("C-c C-y" . term-paste)
        ("C-c d" . interactive-cd)))

(use-package eat
  :ensure t :defer t
  :custom (eat-line-input-ring-size 1024)
  :init
  (defun eat--line--save-history (&rest _)
    "Save `eat-line' history."
    (let ((inhibit-message t))
      (eat--line-write-input-ring)))
  (advice-add #'eat-line-send-input :after #'eat--line--save-history)

  (defun eat-in(&optional dir buffer-name)
    "Create a eat BUFFER-NAME (eat-line-mode) and set `eat--line-input-ring-file-name' is HISTFILE."
    (interactive (list "*eat*" nil))
    (let* ((default-directory dir)
           (eat-buffer-name (or buffer-name (format "*eat:%s*" default-directory))))
      (with-current-buffer (eat)
        (eat-line-mode))
      (pop-to-buffer eat-buffer-name)))

  (defun eat-hist(&optional buffer-name histfile)
    "Create a eat BUFFER-NAME (eat-line-mode) and set `eat--line-input-ring-file-name' is HISTFILE."
    (interactive (list "*eat*" nil))
    (let* ((eat-buffer-name (or buffer-name (format "*eat:%s*" default-directory)))
           (shell-directory-name (locate-user-emacs-file "shell"))
           (histfile (or histfile eat-buffer-name))
           (history-file (expand-file-name
                          (format "%s/%s.history" shell-directory-name
                                  (replace-regexp-in-string
                                   "/" "~" (format "%s.%s" (abbreviate-file-name default-directory) histfile))))))
      (with-current-buffer (eat)
        (eat-line-mode)
        (setq-local eat--line-input-ring-file-name history-file)
        (ignore-errors
          (eat-line-load-input-history-from-file eat--line-input-ring-file-name "bash")))
      (pop-to-buffer eat-buffer-name)))
  (defun eat-run (buffer-name program)
    "Start PROGRAM in a new eat terminal buffer named BUFFER-NAME."
    (interactive "sBuffer name: \nsProgram: ")
    (let* ((eat-buffer-name buffer-name)
           (cmd (split-string-shell-command program))
           (prog (car cmd))
           (args (cdr cmd)))
      (with-current-buffer (apply #'eat prog nil args)
        (eat-line-mode))
      (pop-to-buffer eat-buffer-name)))
  :config
  (define-key eat-line-mode-map [xterm-paste] #'xterm-paste)
  (define-key eat-semi-char-mode-map (kbd "M-o") #'crux-switch-to-previous-buffer)
  (defun eat-kill-process-confirm (orig-fun &rest args)
    (if (y-or-n-p "Kill process? ")
        (apply orig-fun args)))
  (advice-add 'eat-kill-process :around #'eat-kill-process-confirm)
  (defvar-local eat--line-input-ring-file-name nil
    "Name of the file to which the buffer's `eat--line-input-ring' is saved.")
  (defun eat--line-write-input-ring ()
    "Clone from `comint-write-input-ring'."
    (cond ((or (null eat--line-input-ring-file-name)
               (equal eat--line-input-ring-file-name "")
               (null eat--line-input-ring) (ring-empty-p eat--line-input-ring))
           nil)
          ((not (file-writable-p eat--line-input-ring-file-name))
           (message "Cannot write history file %s" eat--line-input-ring-file-name))
          (t
           (let* ((history-buf (get-buffer-create " *Temp Input History*"))
                  (ring eat--line-input-ring)
                  (file eat--line-input-ring-file-name)
                  (index (ring-length ring)))
             (with-current-buffer history-buf
               (erase-buffer)
               (while (> index 0)
                 (setq index (1- index))
                 (insert (ring-ref ring index) "\n"))
               (write-region (buffer-string) nil file nil 'no-message)
               (kill-buffer nil)))))))

(use-package xclip ;; -- don't use xsel
  :ensure t :defer t
  :init
  (add-hook 'tty-setup-hook
            (lambda()(require 'xclip nil t)
              (ignore-errors (xclip-mode)))))

;; BUILTIN
(use-package tramp :defer t ;; version 27
  :init
  (setq tramp-use-scp-direct-remote-copying t
        tramp-copy-size-limit (* 1024 1024) ;; 1MB
        tramp-verbose 3
        tramp-show-ad-hoc-proxies t
        tramp-default-method "ssh"
        tramp-histfile-override nil;
        tramp-allow-unsafe-temporary-files t)
  :config
  (require 'tramp-hlo)
  (tramp-hlo-setup)
  (connection-local-set-profile-variables
   'remote-direct-async-process
   '((tramp-direct-async-process . t)))

  (connection-local-set-profiles
   '(:application tramp :protocol "scp")
   'remote-direct-async-process)
  (setq magit-tramp-pipe-stty-settings 'pty))

(use-package tramp-hlo
  :ensure t :defer t)

(use-package ediff
  :ensure nil :defer t
  :config
  (setq ediff-window-setup-function 'ediff-setup-windows-plain)
  (setq ediff-split-window-function 'split-window-horizontally))

(use-package savehist
  :ensure t :defer t
  :custom (savehist-ignored-variables '(eww-prompt-history compile-command))
  :hook
  (savehist-save .
                 (lambda ()
                   (setq kill-ring
                         (mapcar #'substring-no-properties
                                 (cl-remove-if-not #'stringp kill-ring)))))
  (after-init . savehist-mode))

(use-package autorevert
  ;; revert buffers when their files/state have changed
  :hook ((focus-in after-save) . doom-auto-revert-buffers-h)
  :config
  (setq auto-revert-verbose t ; let us know when it happens
        auto-revert-use-notify nil
        auto-revert-stop-on-user-input nil)
  (defun doom-visible-buffers (&optional buffer-list)
    "Return a list of visible buffers (i.e. not buried)."
    (let ((buffers (delete-dups (mapcar #'window-buffer (window-list)))))
      (if buffer-list (cl-delete-if (lambda (b) (memq b buffer-list)) buffers)
        (delete-dups buffers))))
  (defun doom-auto-revert-buffer-h ()
    "Auto revert current buffer, if necessary."
    (unless (or auto-revert-mode (active-minibuffer-window))
      (let ((auto-revert-mode t)) (auto-revert-handler))))
  (defun doom-auto-revert-buffers-h ()
    "Auto revert stale buffers in visible windows, if necessary."
    (dolist (buf (doom-visible-buffers))
      (with-current-buffer buf (doom-auto-revert-buffer-h)))))

(use-package compile :defer t
  :init (global-set-key (kbd "C-x m") 'compile)
  :custom
  (compilation-always-kill t)       ; kill compilation process before starting another
  (compilation-ask-about-save nil)  ; save all buffers on `compile'
  (compilation-scroll-output t)
  (ansi-color-for-compilation-mode t)
  :config
  (defun compile-to-buffer (command buffer-name &optional comint)
    "Run compile COMMAND and output to BUFFER-NAME. Overwrite if exists."
    (let ((compilation-buffer-name-function
           (lambda (_)
             (format "*compile:%s*" buffer-name))))
      (compile command comint)))
  (add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)
  (defvar project-compile-history (make-hash-table :test 'equal))
  (defun project--get-command-history (project)
    (or (gethash project project-compile-history)
        (puthash project (make-ring 16) project-compile-history)))
  (advice-add #'compilation-read-command :override #'compilation-read-command-project)
  (defun compilation-read-command-project (command &optional prompt)
    "Override compilation-read-command (COMMAND) per project."
    (let* ((project-name (pretty--abbreviate-directory default-directory))
           (history
            (ring-elements (project--get-command-history project-name)))
           (command (or (car history) command))
           (input (read-shell-command
                   (format "%s `%s' [%s]: " (or prompt "Compile")
                           (pretty--abbreviate-directory default-directory) command) nil
                   'history command)))
      (ring-remove+insert+extend (project--get-command-history project-name)
                                 (if (string-empty-p input) command input))))
  (with-eval-after-load 'savehist
    (add-to-list 'savehist-additional-variables 'project-compile-history)))

(use-package epg
  :defer t
  :config (setq epg-pinentry-mode 'loopback))
(use-package epa
  :defer t
  :config (setq epa-armor t))

(use-package delsel
  :defer t
  :init (delete-selection-mode))

(use-package winner
  :init (winner-mode)
  :config
  (defun toggle-delete-other-windows ()
    "Delete other windows in frame if any, or restore previous window config."
    (interactive)
    (if (and winner-mode
             (equal (selected-window) (next-window)))
        (winner-undo)
      (delete-other-windows)))

  (global-set-key (kbd "C-x 1") #'toggle-delete-other-windows))

(use-package eww :defer t
  :custom (eww-auto-rename-buffer 'title)
  :config
  (define-advice eww (:around (oldfun &rest args) always-new-buffer)
    "Always open EWW in a new buffer."
    (let ((current-prefix-arg '(4)))
      (apply oldfun args))))

;; MAIL
(use-package gnus :defer t
  :config
  (setq gnus-select-method '(nntp "news.gmane.io"))
  (setq gnus-summary-line-format "%U%R%z %d %-23,23f (%4,4L) %{%B%}%s\n"
        gnus-sum-thread-tree-root            ""
        gnus-sum-thread-tree-false-root      "──> "
        gnus-sum-thread-tree-leaf-with-other "├─> "
        gnus-sum-thread-tree-vertical        "│ "
        gnus-sum-thread-tree-single-leaf     "└─> "))

;;; THEMES
(use-package theme-buffet
  :ensure t
  :custom
  (theme-buffet-end-user '(:all (modus-vivendi misterioso tsdh-dark)))
  (theme-buffet-menu 'end-user)
  :config
  (defun theme-buffet--get-period-keyword() :all)
  (defun theme-buffet--reload-theme (chosen-theme &optional added-message)
    "Override `theme-buffet--reload-theme'."
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme chosen-theme :no-confirm))
  (theme-buffet--load-random)
  (theme-buffet-timer-mins 15))
;;; MODELINE
(setq mode-line-position
      '((line-number-mode ("(%l" (column-number-mode ",%c")))
        (-4 ":%p" ) (")")))
(setq-default mode-line-buffer-identification
              (propertized-buffer-identification "%b"))
(defsubst modeline-column (pos)
  "Get the column of the position `POS'."
  (save-excursion (goto-char pos) (current-column)))
(defun selection-info()
  "Information about the current selection."
  (when mark-active
    (cl-destructuring-bind (beg . end)
        (cons (region-beginning) (region-end))
      (propertize
       (let ((lines (count-lines beg (min end (point-max)))))
         (concat (cond ((bound-and-true-p rectangle-mark-mode)
                        (let ((cols (abs (- (modeline-column end)
                                            (modeline-column beg)))))
                          (format "(%dx%d)" lines cols)))
                       ((> lines 0) (format "(%d,%d)" lines (- end beg)))
                       ((format "(%d,%d)" 0 (- end beg))))))
       'face 'font-lock-warning-face))))

(setq-default mode-line-format
              '("%e" mode-line-front-space mode-line-mule-info
                mode-line-client mode-line-modified mode-line-remote
                mode-line-frame-identification " "
                mode-line-buffer-identification " "
                mode-line-position (:eval (selection-info))
                (vc-mode vc-mode) " "
                mode-line-modes mode-line-misc-info
                mode-line-end-spaces))

(use-package which-func
  :after imenu
  :config
  (setq-default header-line-format
                (list "▶" '((:eval (propertize (pretty--abbreviate-directory default-directory)
                                               'face 'font-lock-comment-face))
                            "::" (:eval (propertize (or (which-function) "")
                                                    'face 'font-lock-function-name-face))))))

;;; CUSTOMIZE
(defun pretty--abbreviate-directory (dir)
  "Clone `consult--abbreviate-directory(DIR)'."
  (save-match-data
    (let ((adir (abbreviate-file-name dir)))
      (if (string-match "/\\([^/]+\\)/\\([^/]+\\)/\\'" adir)
          (format "…/%s/%s/" (match-string 1 adir) (match-string 2 adir)) adir))))
(defun add-to-hooks (func &rest hooks)
  "Add FUNC to mutil HOOKS."
  (dolist (hook hooks) (add-hook hook func)))
;; enable whitespace-mode
(add-to-hooks 'whitespace-mode
              'prog-mode-hook 'org-mode-hook
              'markdown-mode-hook 'yaml-mode-hook
              'dockerfile-mode-hook)

;; hide the minor modes
(defun purge-minor-modes ()
  "Dont show on modeline."
  (dolist (x hidden-minor-modes nil)
    (let ((trg (cdr (assoc x minor-mode-alist))))
      (when trg (setcar trg "")))))
(add-hook 'after-change-major-mode-hook #'purge-minor-modes)
(defun my-kill-ring-save ()
  "Better than 'kill-ring-save."
  (interactive)
  (if (not mark-active)
      (kill-ring-save (point) (line-end-position))
    (call-interactively 'kill-ring-save)))
(defun indent-and-delete-trailing-whitespace ()
  "Indent and delete trailing whitespace in buffer."
  (interactive)
  (save-excursion (indent-region (point-min) (point-max) nil))
  (delete-trailing-whitespace))
(defun yank-file-path ()
  "Yank file path of buffer."
  (interactive)
  (let ((filename (or (when (eq major-mode 'dired-mode)
                        (dired-get-filename nil t))
                      (if (buffer-file-name) (buffer-file-name)
                        default-directory))))
    (when filename (kill-new filename)
          (message "Yanked %s (%s)" filename (what-line)))))
(defun split-window-vertically-last-buffer (prefix)
  "Split window vertically.
- PREFIX: default(1) is switch to last buffer"
  (interactive "p")
  (split-window-vertically) (other-window 1 nil)
  (if (= prefix 1 ) (switch-to-next-buffer)))
(defun split-window-horizontally-last-buffer (prefix)
  "Split window horizontally.
- PREFIX: default(1) is switch to last buffer"
  (interactive "p")
  (split-window-horizontally) (other-window 1 nil)
  (if (= prefix 1 ) (switch-to-next-buffer)))
(defun insert-temp-filename()
  "Insert new temp file and kill to yank ring."
  (interactive)
  (let ((file
         (concat (file-name-as-directory temporary-file-directory)
                 (make-temp-name
                  (format "%s_" (format-time-string "%Y%m%dT%H%M%S"))))))
    (kill-new file) (insert file)))
(defun insert-datetime()
  "Insert datetime."
  (interactive)
  (let* ((time (org-read-date t 'totime))
         ;; Build all the formats
         (formats (list
                   (format-time-string "%s" time t)
                   (format-time-string "%Y%m%dT%H%M%S" time t)
                   (format-time-string "%Y-%m-%dT%H:%M:%S" time t)
                   (format-time-string "%Y-%m-%d %H:%M:%S" time t)
                   (format-time-string "%Y-%m-%d %H:%M:%S %z" time t)
                   (format-time-string "%Y-%m-%d %H:%M:%S %z" time nil)
                   (format-time-string "%Y/%m/%d" time nil) (format-time-string "%Y-%m-%d" time nil)
                   (format-time-string "%d/%m/%Y" time nil) (format-time-string "%d-%m-%Y" time nil)))
         (format (completing-read "Insert date: " formats)))
    (insert format)))
(defun linux-stat-file()
  "Run stat command in linux in current file."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode) default-directory
                    (buffer-file-name))))
    (when filename
      (shell-command (format "stat '%s'; file '%s'" filename filename)))))
(defun copy-region-to-scratch (&optional prefix file)
  "Copy region to a new scratch or FILE."
  (interactive"P")
  (let* ((buffer-substring-func (if prefix 'buffer-substring 'buffer-substring-no-properties))
         (string
          (cond
           ((and (bound-and-true-p rectangle-mark-mode) (use-region-p))
            (mapconcat 'concat (extract-rectangle (region-beginning) (region-end)) "\n"))
           ((use-region-p) (funcall buffer-substring-func (point) (mark)))
           (t (funcall buffer-substring-func (point-min) (point-max)))))
         (buffer-name (format "%s_%s" (if (buffer-file-name)
                                          (file-name-base (buffer-file-name))
                                        (buffer-name))
                              (format-time-string "%Y%m%dT%H%M%S")))
         (buffer (get-buffer-create buffer-name)))
    (with-current-buffer buffer
      (insert string)
      (if file (write-file file nil))
      (switch-to-buffer (current-buffer)))))
(defun save-region-to-temp (&optional prefix)
  "Save region to a tempfile, if PREFIX is set, prompt for file name."
  (interactive "P")
  (let ((filename
         (make-temp-file
          (concat (file-name-base (buffer-name)) "_"
                  (unless (string-prefix-p "*scratch-" (buffer-name))
                    (format-time-string "%Y%m%dT%H%M%S_")))
          nil (file-name-extension (buffer-name) t))))
    (copy-region-to-scratch nil (if prefix (read-file-name "Save to file: " nil filename) filename))))
(defun find-file-rec ()
  "Find a file in the current working directory recursively."
  (interactive)
  (let ((find-files-program
         (cond
          ((executable-find "rg") '("rg" "--color=never" "--files"))
          ((executable-find "find") '("find" "-type" "f")))))
    (find-file
     (completing-read
      "Find file: " (apply #'process-lines find-files-program)))))
(defun eww-search-local-help ()
  "Search with keyword from local-help."
  (interactive)
  (let ((help (help-at-pt-kbd-string)))
    (if help (eww (read-string "Search: " help)) (message "Nothing!"))))

(defun async-shell-from-region (start end &optional command)
  "Run async shell from region(START END &optional COMMAND)."
  (interactive
   (let (string)
     (unless (mark)
       (user-error "The mark is not set now, so there is no region"))
     (setq string (read-shell-command "async-shell: "
                                      (buffer-substring-no-properties (region-beginning) (region-end))))
     (list (region-beginning) (region-end) string)))
  (let ((bufname (car (split-string (substring command 0 (if (< (length command) 9) (length command) 9))))))
    (async-shell-command command (format "*shell:%s:%s*" bufname (format-time-string "%Y%m%dT%H%M%S")))))

(defmacro with-file-contents (file &rest body)
  "Execute BODY with FILE contents."
  `(with-temp-buffer
     (insert-file-contents ,file)
     ,@body))
(defmacro create-file-with-content (file content)
  "Create FILE with CONTENT."
  `(progn
     (unless (file-exists-p (file-name-directory ,file))
       (make-directory (file-name-directory ,file) t))
     (with-temp-file ,file
       (insert ,content))))

(defun shell-dtach (&optional buffer sockfile)
  "Start dtach in shell(BUFFER)."
  (interactive (list nil
                     (and current-prefix-arg
                          (read-file-name "Sock file: "))))
  (let* ((explicit-shell-file-name (if (executable-find "dtach")
                                       "dtach" nil))
         (file-name (or sockfile
                        (format "/tmp/%s.dtach"
                                (replace-regexp-in-string
                                 "/" "~" default-directory))))
         (explicit-dtach-args `("-A" ,file-name "-z"
                                "/bin/bash" "--noediting" "-login")))
    (if buffer
        (shell buffer)
      (if sockfile
          (shell-hist (format "*dtach:%s*" sockfile))
        (shell-hist (format "*dtach:%s*" default-directory))))))

(defun ~import-txgvnn-gpg-key()
  (interactive)
  (url-retrieve "https://github.com/txgvnn.gpg"
                (lambda (arg)
                  (cond ((equal :error (car arg)) (message arg))
                        (t (with-current-buffer
                               (current-buffer) (goto-char (point-min)) (re-search-forward "^$")
                               (epa-import-keys-region (+ 1 (point)) (point-max))))))))


(global-set-key (kbd "M-D") 'kill-whole-line)
(global-set-key (kbd "M-w") 'my-kill-ring-save)
(global-set-key (kbd "C-x C-@") 'pop-to-mark-command)
(global-set-key (kbd "C-x C-SPC") 'pop-to-mark-command)
(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key (kbd "M-s e") 'eww)
(global-set-key (kbd "M-s E") 'eww-search-local-help)
(global-set-key (kbd "M-s f") 'find-file-rec)
(global-set-key (kbd "C-M-_") 'dabbrev-completion)
(global-set-key (kbd "C-c h") 'eldoc)
(global-set-key (kbd "C-x / .") 'delete-trailing-whitespace)
(global-set-key (kbd "C-x / ;") 'indent-and-delete-trailing-whitespace)
(global-set-key (kbd "C-x / b") 'rename-buffer)
(global-set-key (kbd "C-x / o") 'org-agenda)
(global-set-key (kbd "C-x / p") 'yank-file-path)
(global-set-key (kbd "C-x / r") 'revert-buffer)
(global-set-key (kbd "C-x / a") 'linux-stat-file)
(global-set-key (kbd "C-x / n") 'insert-temp-filename)
(global-set-key (kbd "C-x / d") 'insert-datetime)
(global-set-key (kbd "C-x / D") 'org-time-stamp)
(global-set-key (kbd "C-x / x") 'save-region-to-temp)
(global-set-key (kbd "C-x / c") 'copy-region-to-scratch)
(global-set-key (kbd "C-x / t") 'untabify)
(global-set-key (kbd "C-x / T") 'tabify)
(global-set-key (kbd "C-x / l") 'toggle-truncate-lines)
(global-set-key (kbd "C-x / f") 'flush-lines)
(global-set-key (kbd "C-x O") #'~fast-and-furious)
(global-set-key (kbd "C-x 2") 'split-window-vertically-last-buffer)
(global-set-key (kbd "C-x 3") 'split-window-horizontally-last-buffer)
(global-set-key (kbd "C-x 4 C-v") 'scroll-other-window)
(global-set-key (kbd "C-x 4 M-v") 'scroll-other-window-down)
(global-set-key (kbd "C-x 4 M-<") 'beginning-of-buffer-other-window)
(global-set-key (kbd "C-x 4 M->") 'end-of-buffer-other-window)
(global-set-key (kbd "M-z") 'zap-up-to-char)
(global-set-key (kbd "ESC <up>") #'(lambda () (interactive) (previous-line 3)))
(global-set-key (kbd "ESC <down>") #'(lambda () (interactive) (next-line 3)))
(global-set-key (kbd "M-<up>") #'(lambda () (interactive) (previous-line 3)))
(global-set-key (kbd "M-<down>") #'(lambda () (interactive) (next-line 3)))

(set-default-coding-systems 'utf-8)
(prefer-coding-system 'utf-8)
(setq select-safe-coding-system-function t
      create-lockfiles nil
      auto-save-file-name-transforms `((".*" ,temporary-file-directory t))
      backup-directory-alist `((".*" . ,temporary-file-directory)))
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)
(setq redisplay-skip-fontification-on-input t)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(Buffer-menu-use-header-line nil)
 '(auto-revert-mode-text " ~")
 '(backup-by-copying t)
 '(browse-url-browser-function 'eww-browse-url)
 '(column-number-mode t)
 '(cursor-in-non-selected-windows nil)
 '(default-input-method "vietnamese-telex")
 '(delete-old-versions t)
 '(delete-selection-mode t)
 '(eldoc-minor-mode-string " ð")
 '(electric-indent-mode nil)
 '(enable-local-variables :all)
 '(enable-recursive-minibuffers t)
 '(ffap-machine-p-known 'reject)
 '(find-file-existing-other-name nil)
 '(global-hl-line-mode t)
 '(highlight-nonselected-windows nil)
 '(indent-tabs-mode nil)
 '(inhibit-default-init nil)
 '(inhibit-startup-screen t)
 '(initial-major-mode 'org-mode)
 '(initial-scratch-message nil)
 '(kill-do-not-save-duplicates t)
 '(make-backup-files nil)
 '(menu-bar-mode nil)
 '(minibuffer-depth-indicate-mode t)
 '(package-vc-selected-packages '((monet :url "https://github.com/stevemolitor/monet")))
 '(proced-tree-flag t)
 '(read-quoted-char-radix 16)
 '(repeat-mode t)
 '(ring-bell-function #'ignore)
 '(save-interprogram-paste-before-kill t)
 '(scroll-bar-mode nil)
 '(shell-command-prompt-show-cwd t)
 '(show-paren-mode t)
 '(tab-always-indent 'complete)
 '(tab-stop-list '(4 8 12 16 20 24 28 32 36))
 '(tab-width 4)
 '(tool-bar-mode nil)
 '(use-dialog-box nil)
 '(vc-follow-symlinks nil)
 '(version-control t)
 '(warning-suppress-log-types '((comp)))
 '(whitespace-style
   '(face tabs trailing space-before-tab newline empty tab-mark))
 '(x-select-request-type '(COMPOUND_TEXT UTF8_STRING STRING TEXT)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;;; PATCHING
(if (boundp 'use-short-answers)
    (setq use-short-answers t)
  (advice-add 'yes-or-no-p :override #'y-or-n-p))
(unless (daemonp)
  (advice-add #'display-startup-echo-area-message :override #'ignore))
(advice-add #'base64-encode-region
            :before (lambda (&rest _args)
                      "Pass prefix arg as third arg to `base64-encode-region'."
                      (interactive "r\nP")))
(setq minibuffer-prompt-properties
      '(read-only t cursor-intangible t face minibuffer-prompt))
(add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
(let ((shell-directory-name (locate-user-emacs-file "shell")))
  (make-directory shell-directory-name t))

;;; DEVELOPMENT ENV
(use-package treesit
  :demand t
  :init
  (dolist (mapping '((python-mode . python-ts-mode)
                     (css-mode . css-ts-mode)
                     (sh-mode . bash-ts-mode)
                     (yaml-mode . yaml-ts-mode)
                     (js-json-mode . json-ts-mode)
                     (json-mode . json-ts-mode)
                     (javascript-mode . js-ts-mode)
                     (typescript-mode . typescript-ts-mode)
                     (c-mode . c-ts-mode)
                     (java-mode . java-ts-mode)
                     (c++-mode . c++-ts-mode)))
    (add-to-list 'major-mode-remap-alist mapping))
  (setq treesit-extra-load-path '("~/.guix-profile/lib/tree-sitter")))

(use-package combobulate
  :ensure t :defer t
  :hook
  ((python-ts-mode js-ts-mode css-ts-mode tsx-ts-mode typescript-ts-mode) . combobulate-mode))
;; (yaml-ts-mode . combobulate-mode)

(defun package-installs (&rest packages)
  "Install PACKAGES."
  (dolist (package packages) (package-install package)))

;; .emacs
(use-package elisp-mode
  :defer t
  :config
  ;; Prevent byte complation of .emacs file, which can introduce bugs.
  ;; BUG: Emacs try to install packages that are already installed.
  (defun elisp-flymake-byte-compile-do-nothing(report-fn &rest _args)())
  (advice-add 'elisp-flymake-byte-compile :override #'elisp-flymake-byte-compile-do-nothing))

(defun develop-dot()
  "Diff 'user-init-file - .emacs."
  (interactive)
  (let ((upstream (make-temp-file ".emacs")))
    (url-copy-file "https://raw.githubusercontent.com/TxGVNN/dots/master/.emacs" upstream t)
    (diff user-init-file upstream)
    (other-window 1 nil)
    (message "Override %s by %s to update" user-init-file upstream)))

;; org-mode
(use-package org :defer t
  :hook
  (org-mode . org-indent-mode)
  :config
  (defun org-open-at-point-of-babel-call()
    (let* ((context (org-element-lineage (org-element-context) '(babel-call) t))
           (type (org-element-type context))
           (value (org-element-property :value context)))
      (if (eq type 'babel-call)
          ;; remove '()' string in value then to assign to project-task
          (let ((project-task (replace-regexp-in-string "()" "" value)))
            (project-tasks-goto-task project-task) t)
        nil)))
  (add-to-list 'org-open-at-point-functions #'org-open-at-point-of-babel-call)
  (require 'ob-shell)
  (add-to-list 'hidden-minor-modes 'org-indent-mode)
  (define-key org-src-mode-map (kbd "C-c C-c") #'org-edit-src-exit)
  (global-set-key (kbd "C-c l") #'org-store-link)
  (global-set-key (kbd "C-c C-l") #'org-insert-link)
  (org-babel-do-load-languages
   'org-babel-do-load-languages
   '((emacs-lisp . t) (shell . t)))
  (setq org-enforce-todo-dependencies t
        org-adapt-indentation nil
        org-odd-levels-only nil
        org-hide-leading-stars t
        org-src-tab-acts-natively t
        org-edit-src-content-indentation 0
        org-tags-match-list-sublevels 'indented
        org-log-done 'time
        org-use-property-inheritance t
        org-agenda-prefix-format
        (quote ((agenda . " %i %-12:c%?-12t%-5e% s")
                (todo . " %i %-12:c %-5e")
                (tags . " %i %-12:c %-5e")
                (search . " %i %-12:c %-5e")))
        org-todo-keyword-faces (quote (("KILL" . error) ("STRT" . highlight)
                                       ("PAUS" . org-warning) ("REVIEW" . warning) ("AWPY" . success)))
        org-todo-keywords
        (quote
         ((sequence "TODO(t)" "|" "DONE(d)")
          (sequence "IDEA(i)" "STRT(s)" "PAUS(p)" "REVIEW(r)" "AWPY(a)" "|" "KILL(k)")))))

(use-package org-capture
  :defer t
  :config
  (defun org-capture-find-file-location ()
    "Find a file for org-capture."
    (let* ((file (org-capture-expand-file
                  (read-file-name "Select org file: " default-directory))))
      (set-buffer (or (org-find-base-buffer-visiting file)
                      (progn (org-capture-put :new-buffer t)
                             (find-file-noselect file))))
      (unless (derived-mode-p 'org-mode)
        (org-display-warning
         (format "Capture requirement: switching buffer %S to Org mode"
                 (current-buffer)))
        (org-mode))
      (org-capture-put-target-region-and-position)
      (widen)
      (goto-char (point-max))
      (unless (bolp) (insert "\n"))
      (beginning-of-line 0)))

  (setq org-capture-templates
        '(("t" "Task" plain (function org-capture-find-file-location)
           "* TODO %?\n:PROPERTIES:\n:CREATED: %T\n:END:\n%a\n%i"))))

(use-package org-bullets
  :ensure t :defer t
  :init (add-hook 'org-mode-hook #'org-bullets-mode))

(use-package org-transclusion
  :ensure t :defer t
  :bind
  ("C-c n t" . org-transclusion-add)
  :custom-face
  (org-transclusion ((t (:inherit org-meta-line)))))

(use-package org-tanglesync
  :ensure t :defer t
  :commands (org-tanglesync-process-buffer-interactive))



(use-package ob-compile :ensure t :defer t
  :config (add-hook 'compilation-finish-functions #'ob-compile-save-file))

(use-package yaml-mode
  :ensure t :defer t
  :hook
  (yaml-mode  . flymake-mode)
  (yaml-mode  . flymake-yamllint-setup))

(use-package markdown-mode :ensure t :defer t)

;; Go: `go install golang.org/x/tools/gopls'
(use-package go-ts-mode
  :defer t
  :config
  (defun go-enable-eglot()
    (interactive)
    (when (fboundp 'eglot-ensure)
      (add-hook 'go-ts-mode-hook #'eglot-ensure)
      (add-hook 'before-save-hook #'eglot-format-buffer t t))))

;; Python: `pip install python-lsp-server[all]'
(use-package python
  :config
  (setq python-indent-guess-indent-offset-verbose nil)
  (when (executable-find "python3")
    (setq python-shell-interpreter "python3"))
  (defun python-pip-install-requirements()
    (interactive)
    (let ((default-directory (project-root (project-current t))))
      (async-shell-command "pwd; which pip; pip install -r requirements.txt")))
  (defun python-docs (w)
    "Launch PyDOC on the Word at Point"
    (interactive
     (list (let* ((word (thing-at-point 'word))
                  (input (read-string
                          (format "pydoc entry%s: "
                                  (if (not word) "" (format " (default %s)" word))))))
             (if (string= input "")
                 (if (not word) (error "No pydoc args given") word) input))))
    (ignore-errors (kill-buffer "*PYDOCS*"))
    (shell-command (concat "python -c \"from pydoc import help;help(\'" w "\')\"") "*PYDOCS*")
    (view-buffer-other-window "*PYDOCS*" t 'kill-buffer)))

;; Erlang
(use-package erlang :ensure t :defer t)

;; Terraform
(use-package terraform-mode :ensure t :defer t)
(use-package terraform-doc :ensure t :defer t)

;; Ansible
(use-package ansible
  :ensure t :defer t
  :hook (ansible .
                 (lambda()
                   (ansible-doc-mode)
                   (add-to-list 'company-backends 'company-ansible))))
(use-package ansible-doc
  :ensure t :defer t
  :config (define-key ansible-doc-mode-map (kbd "M-?") #'ansible-doc))

;; Java - https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz"
;; (use-package java-ts-mode
;;   :hook (java-ts-mode . eglot-ensure))

(use-package lua-mode
  :ensure t :defer t)
;; HTML
(use-package indent-guide
  :ensure t :defer t
  :hook (html-mode . indent-guide-mode)
  :config (set-face-foreground 'indent-guide-face "dimgray"))
(use-package sgml-mode
  :defer t
  :config
  (define-key html-mode-map (kbd "M-o") #'crux-switch-to-previous-buffer))

(defun develop-gitlab-ci()
  "Gitlab-CI development."
  (interactive)
  (package-installs 'gitlab-ci-mode 'gitlab-pipeline))

(defun develop-vagrant()
  "Vagrant tools."
  (interactive)
  (package-installs 'vagrant 'vagrant-tramp))

;; Docker
(use-package docker :defer t
  :config (setq docker-run-async-with-buffer-function #'docker-run-async-with-buffer-shell))
(use-package dockerfile-mode :ensure t :defer t)
(use-package docker-compose-mode :ensure t :defer t)
;; restclient
(use-package restclient-jq :ensure t :defer t)
(use-package restclient :ensure t :defer t
  :config
  (require 'restclient-jq)
  (defun restclient-get-response-headers ()
    "Returns alist of current response headers. Works *only* with with
hook called from `restclient-http-send-current-raw', usually
bound to C-c C-r."
    (let ((start (point-min))
          (headers-end (+ 1 (string-match "\n\n" (buffer-substring-no-properties (point-min) (point-max))))))
      (restclient-parse-headers (buffer-substring-no-properties start headers-end))))
  (defun restclient-set-var-from-header (var header)
    (restclient-set-var var (cdr (assoc header (restclient-get-response-headers))))))

(defun develop-kubernetes()
  "Kubernetes tools."
  (interactive)
  (package-installs 'kubel 'kubedoc 'k8s-mode))
(use-package nginx-mode :ensure t :defer t)
(defun develop-keylog ()
  "Keycast and log."
  (interactive)
  (package-installs 'keycast 'interaction-log))
(use-package keycast :defer t
  :config (setq keycast-mode-line-insert-after 'mode-line-misc-info))

(use-package x509-mode :ensure t :defer t)

;; keep personal settings not in the .emacs file
(let ((personal-settings (locate-user-emacs-file "personal.el")))
  (when (file-exists-p personal-settings)
    (load-file personal-settings)))

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "init-time %.03fs"
                     (float-time (time-subtract after-init-time before-init-time)))))
(setq custom-file (concat temporary-file-directory "custom.el"))

(provide '.emacs)
;;; .emacs ends here
