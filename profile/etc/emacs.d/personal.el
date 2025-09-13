;; C-x P
(setq project-temp-root (concat (getenv "WORKSPACE") "/"))

(unless (package-installed-p 'gptel)
  (package-vc-install "https://github.com/TxGVNN/gptel" "feature/edit-tool-results"))

(use-package gptel
  :defer t
  :bind ("C-x / g" . gptel-menu)
  :custom
  (gptel-cache t)
  (gptel-max-tokens 8192)
  (gptel-default-mode 'org-mode)
  (gptel-prompt-prefix-alist
   '((markdown-mode . "## ")
     (org-mode . "** ")
     (text-mode . "## ")))
  (gptel-response-prefix-alist
   '((markdown-mode . "### ")
     (org-mode . "*** ")
     (text-mode . "### ")))
  (gptel-use-tools t)
  (gptel-include-tool-results t)
  (gptel-include-reasoning nil)
  (gptel-expert-commands t))

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

(use-package copilot
  :defer t
  :commands (copilot-mode copilot-accept-completion-by-line copilot-accept-completion)
  :init
  (global-set-key (kbd "C-c p l") #'copilot-accept-completion-by-line)
  (global-set-key (kbd "C-c p r") #'copilot-accept-completion)

  (defun completion-customize(&optional prefix)
    "Complete and Yasnippet(PREFIX)."
    (interactive "P")
    (if prefix
        (consult-yasnippet nil)
      (if (copilot--overlay-visible)
          (progn
            (copilot-accept-completion-by-line))
        (copilot-complete))))
  (setq copilot-version "1.363.0")
  :config
  (global-set-key (kbd "M-]") #'completion-customize)
  (define-key copilot-mode-map (kbd "M-n") #'copilot-next-completion)
  (define-key copilot-mode-map (kbd "M-p") #'copilot-previous-completion)

  (defun copilot--ensure-enabled (orig-fun &rest args)
    (if (and (not (bound-and-true-p copilot-mode))
             (y-or-n-p "Enable `Copilot' for this buffer? "))
        (copilot-mode)
      (apply orig-fun args)))
  (advice-add 'copilot-accept-completion-by-line :around #'copilot--ensure-enabled)
  (advice-add 'copilot-accept-completion :around #'copilot--ensure-enabled))
