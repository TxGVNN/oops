;;; early-init.el -*- lexical-binding: t; -*-

;; Emacs 27.1 introduced early-init.el, which is run before init.el, before
;; package and UI initialization happens, and before site files are loaded.

;; A big contributor to startup times is garbage collection. We up the gc
;; threshold to temporarily prevent it from running, then reset it later by
;; enabling `gcmh-mode'. Not resetting it will cause stuttering/freezes.
(setq gc-cons-threshold most-positive-fixnum)

;; PERF: Don't use precious startup time checking mtime on elisp bytecode.
;;   Ensuring correctness is 'doom sync's job, not the interactive session's.
;;   Still, stale byte-code will cause *heavy* losses in startup efficiency.
(setq load-prefer-newer noninteractive)

;; UX: Respect DEBUG envvar as an alternative to --debug-init, and to make are
;;   startup sufficiently verbose from this point on.
(when (getenv-internal "DEBUG")
  (setq init-file-debug t
        debug-on-error t))

;; Resizing the Emacs frame can be a terribly expensive part of changing the
;; font. By inhibiting this, we easily halve startup times with fonts that are
;; larger than the system default.
(setq frame-inhibit-implied-resize t)


;; Contrary to what many Emacs users have in their configs, you don't need more
;; than this to make UTF-8 the default coding system:
(set-language-environment "UTF-8")
;; ...but the clipboard's on Windows could be in another encoding (likely
;; utf-16), so let Emacs/the OS decide what to use there.
(setq selection-coding-system 'utf-8) ; with sugar on top

;; Reduce *Message* noise at startup. An empty scratch buffer (or the dashboard)
;; is more than enough.
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name
      inhibit-default-init t
      ;; Shave seconds off startup time by starting the scratch buffer in
      ;; `fundamental-mode', rather than, say, `org-mode' or `text-mode', which
      ;; pull in a ton of packages. `doom/open-scratch-buffer' provides a better
      ;; scratch buffer anyway.
      initial-major-mode 'fundamental-mode
      initial-scratch-message nil)


;; Don't ping things that look like domain names.
(setq ffap-machine-p-known 'reject)

;; Prevent the glimpse of un-styled Emacs by disabling these UI elements early.
(setq tool-bar-mode nil
      menu-bar-mode nil)

(setq package-directory-list '("~/.guix-profile/share/emacs/site-lisp"))
(push 'ace-window package-activated-list)
(push 'ansible-doc package-activated-list)
(push 'anzu package-activated-list)
(push 'avy package-activated-list)
(push 'beacon package-activated-list)
(push 'cape package-activated-list)
(push 'closql package-activated-list)
(push 'combobulate package-activated-list)
(push 'consult package-activated-list)
(push 'consult-yasnippet package-activated-list)
(push 'corfu package-activated-list)
(push 'corfu-terminal package-activated-list)
(push 'crux package-activated-list)
(push 'denote package-activated-list)
(push 'detached package-activated-list)
(push 'diredfl package-activated-list)
(push 'docker package-activated-list)
(push 'docker-compose-mode package-activated-list)
(push 'dockerfile-mode package-activated-list)
(push 'dumb-jump package-activated-list)
(push 'eat package-activated-list)
(push 'eev package-activated-list)
(push 'elfeed package-activated-list)
(push 'elpa-mirror package-activated-list)
(push 'embark package-activated-list)
(push 'embark-consult package-activated-list)
(push 'engine-mode package-activated-list)
(push 'envrc package-activated-list)
(push 'erlang package-activated-list)
(push 'expreg package-activated-list)
(push 'forge package-activated-list)
(push 'gcmh package-activated-list)
(push 'geiser package-activated-list)
(push 'geiser-guile package-activated-list)
(push 'gist package-activated-list)
(push 'git-gutter package-activated-list)
(push 'git-link package-activated-list)
(push 'guix package-activated-list)
(push 'helpful package-activated-list)
(push 'hl-todo package-activated-list)
(push 'magit package-activated-list)
(push 'magit-todos package-activated-list)
(push 'marginalia package-activated-list)
(push 'move-text package-activated-list)
(push 'multiple-cursors package-activated-list)
(push 'nginx-mode package-activated-list)
(push 'ob-compile package-activated-list)
(push 'orderless package-activated-list)
(push 'org-alert package-activated-list)
(push 'org-bullets package-activated-list)
(push 'pcmpl-args package-activated-list)
(push 'perspective package-activated-list)
(push 'pinentry package-activated-list)
(push 'project package-activated-list)
(push 'project-tasks package-activated-list)
(push 'rainbow-delimiters package-activated-list)
(push 'rainbow-mode package-activated-list)
(push 'rg package-activated-list)
(push 'shell-command+ package-activated-list)
(push 'smartparens package-activated-list)
(push 'symbol-overlay package-activated-list)
(push 'transient package-activated-list)
(push 'terraform-mode package-activated-list)
(push 'use-package package-activated-list)
(push 'vertico package-activated-list)
(push 'volatile-highlights package-activated-list)
(push 'vundo package-activated-list)
(push 'xclip package-activated-list)
(push 'yaml-mode package-activated-list)
(push 'yasnippet package-activated-list)
(push 'yasnippet-snippets package-activated-list)
(push 'ztree package-activated-list)
