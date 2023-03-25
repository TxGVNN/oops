;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules (gnu home)
             (gnu packages)
             (gnu services)
             (gnu home services shells)
             (gnu packages emacs)
             (gnu home services)
             (gnu packages compression)
             (guix gexp)
             (guxti packages emacs)
             (guxti home-services-utils)
             (guxti home-services emacs))

(define profile-packages
  (map specification->package
       '(;; libs
         "glibc-locales"
         "tree-sitter"
         "tree-sitter-bash"
         "tree-sitter-c"
         "tree-sitter-c-sharp"
         "tree-sitter-cli"
         "tree-sitter-clojure"
         "tree-sitter-cpp"
         "tree-sitter-css"
         "tree-sitter-elixir"
         "tree-sitter-elm"
         "tree-sitter-go"
         "tree-sitter-haskell"
         "tree-sitter-html"
         "tree-sitter-java"
         "tree-sitter-javascript"
         "tree-sitter-json"
         "tree-sitter-julia"
         "tree-sitter-markdown"
         "tree-sitter-markdown-gfm"
         "tree-sitter-ocaml"
         "tree-sitter-org"
         "tree-sitter-php"
         "tree-sitter-python"
         "tree-sitter-r"
         "tree-sitter-racket"
         "tree-sitter-ruby"
         "tree-sitter-rust"
         "tree-sitter-scheme"
         "tree-sitter-typescript"
         ;; languages
         "clang"
         "go"
         "guile"
         "node"
         "python"
         "python-lsp-server"
         ;; tools
         "direnv"
         "dropbear"
         "dtach"
         "git-crypt"
         "global"
         "ripgrep"
         "rsync"
         "screen"
         "socat"
         "tmate"
         "zip")))

(define emacs-packages
  (map specification->package
       '("emacs-ztree"
         "emacs-forge"
         "emacs-helpful"
         "emacs-elisp-refs"
         "emacs-magit-todos"
         "emacs-perspective@2.16.20230114"
         "emacs-crux"
         "emacs-elfeed"
         "emacs-detached"
         "emacs-ace-window"
         "emacs-anzu"
         "emacs-avy"
         "emacs-beacon"
         "emacs-cape"
         "emacs-consult@0.31.20230224"
         "emacs-corfu"
         "emacs-corfu-terminal"
         "emacs-diredfl"
         "emacs-dumb-jump"
         "emacs-embark@0.21.1.20230225"
         "emacs-embark-consult"
         "emacs-envrc"
         "emacs-expand-region"
         "emacs-geiser"
         "emacs-geiser-guile"
         "emacs-git-gutter"
         "emacs-guix"
         "emacs-hl-todo"
         "emacs-magit"
         "emacs-marginalia"
         "emacs-move-text"
         "emacs-multiple-cursors"
         "emacs-orderless"
         "emacs-pinentry"
         "emacs-project"
         "emacs-rainbow-delimiters"
         "emacs-rainbow-mode"
         "emacs-rg"
         "emacs-shell-command+"
         "emacs-smartparens"
         "emacs-symbol-overlay"
         "emacs-transient"
         "emacs-use-package"
         "emacs-vertico"
         "emacs-volatile-highlights"
         "emacs-vterm"
         "emacs-vundo"
         "emacs-yasnippet"
         "emacs-consult-yasnippet")))

(home-environment
 ;; Below is the list of packages that will show up in your
 ;; Home profile, under ~/.guix-home/profile.
 (packages profile-packages)

 (services
  (list (service home-bash-service-type
                 (home-bash-configuration
                  (guix-defaults? #f)
                  (bashrc (list (local-file "../profile/.bashrc" "bashrc")))
                  (bash-profile (list (local-file "../profile/.bash_profile"
                                                  "bash_profile")))
                  (bash-logout (list (local-file "../profile/.bash_logout"
                                                 "bash_logout")))))
        (service home-emacs-service-type
                 (home-emacs-configuration
                  (package emacs-next)
                  (server-mode? #t)
                  ;; (rebuild-elisp-packages? #f)
                  (early-init-el
                   `(,(slurp-file-gexp (local-file "../profile/.emacs.d/early-init.el"))))
                  (init-el
                   `(,(slurp-file-gexp (local-file "../profile/.emacs.d/init.el"))))
                  (elisp-packages emacs-packages))))))
