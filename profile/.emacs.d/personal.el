;; C-x P
(setq project-temp-root "/workspace/")

;; Setup straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (straight-vc-git-default-clone-depth 1)
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
(straight-use-package 'use-package)

;; Copilot
(use-package copilot
  :straight (:host github :repo "zerolfx/copilot.el" :files ("dist" "*.el"))
  :ensure t
  :init (add-hook 'prog-mode-hook 'copilot-mode)
  :config
  (setq copilot-node-executable "node")
  (global-set-key (kbd "C-c p c") 'copilot-accept-completion)
  (defun completion-customize(&optional prefix)
    "Complete and Yasnippet(PREFIX)."
    (interactive "P")
    (if prefix
        (consult-yasnippet nil)
      (call-interactively 'copilot-accept-completion))))
