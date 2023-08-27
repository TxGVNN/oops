;; C-x P
(setq project-temp-root (concat (getenv "WORKSPACE") "/"))

(unless (package-installed-p 'copilot)
  (package-vc-install "https://github.com/zerolfx/copilot.el"))
(add-hook 'prog-mode-hook 'copilot-mode)
(with-eval-after-load 'copilot
  (setq copilot-node-executable "node")
  (defun completion-customize(&optional prefix)
    "Complete and Yasnippet(PREFIX)."
    (interactive "P")
    (if prefix
        (consult-yasnippet nil)
      (if (copilot--overlay-visible)
          (progn
            (copilot-accept-completion-by-line))
        (copilot-complete))))
  (define-key copilot-mode-map (kbd "M-n") #'copilot-next-completion)
  (define-key copilot-mode-map (kbd "M-p") #'copilot-previous-completion))
