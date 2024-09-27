;; C-x P
(setq project-temp-root (concat (getenv "WORKSPACE") "/"))

(use-package gptel
  :defer t
  :bind ("C-x / g" . gptel-menu)
  (:map gptel-mode-map ("C-x s" . gptel-save-session)))

(unless (package-installed-p 'copilot)
  (package-vc-install "https://github.com/zerolfx/copilot.el"))

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
