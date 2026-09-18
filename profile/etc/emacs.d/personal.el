;; C-x P
(setq project-temp-root (concat (getenv "WORKSPACE") "/"))

(unless (package-installed-p 'gptel)
  (package-vc-install "https://github.com/txgvnn/gptel" "develop-20260505"))

(use-package gptel
  :defer t
  :bind ("C-c a" . gptel-menu)
  (:map gptel-mode-map ("C-x M-s" . gptel-save-session))
  :hook
  (gptel-mode . gptel-highlight-mode)
  :custom-face
  (gptel-response-highlight ((t (:background "#202030"))))
  :custom
  (gptel-log-level 'debug)
  (gptel-cache t)
  (gptel-max-tokens 8192)
  (gptel-default-mode 'org-mode)
  (gptel-org-branching-context t)
  (gptel-org-convert-response nil)
  (gptel-prompt-prefix-alist
   '((markdown-mode . "## ")
     (org-mode . "@user\n")
     (text-mode . "## ")))
  (gptel-response-prefix-alist
   '((markdown-mode . "### ")
     (org-mode . "@assistant\n")
     (text-mode . "### ")))
  (gptel-use-tools t)
  (gptel-confirm-tool-calls t)
  (gptel-include-tool-results t)
  (gptel-include-reasoning nil)
  (gptel-expert-commands t)
  (gptel-highlight-methods '(face)))

(unless (package-installed-p 'gptel-commit)
  (package-vc-install "https://github.com/lakkiy/gptel-commit")
  (let ((default-directory "~/.emacs.d/elpa/gptel-commit"))
    (when (file-exists-p default-directory)
      (shell-command "git checkout 2b1063a; rm -rf *.elc"))))

(use-package gptel-commit
  :ensure t :defer t
  :after (gptel))

(unless (package-installed-p 'copilot)
  (package-vc-install "https://github.com/zerolfx/copilot.el")
  (let ((default-directory "~/.emacs.d/elpa/copilot/"))
    (when (file-exists-p default-directory)
      (shell-command "git checkout 4f51b3c; rm -rf *.elc"))))
