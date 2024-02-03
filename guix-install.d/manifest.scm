;; This "manifest" file can be passed to 'guix package -m' to reproduce
;; the content of your profile.  This is "symbolic": it only specifies
;; package names.  To reproduce the exact same profile, you also need to
;; capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules (guix inferior)
             (guix channels)
             (srfi srfi-1))   ;; for 'first'

(define channels
  (list (channel
         (name 'guix)
         (url "https://git.savannah.gnu.org/git/guix.git")
         (commit "aae61f54ff6acf5cc0e0355dc85babf29f625660"))))

(define inferior
  (inferior-for-channels channels))

(packages->manifest
 (append
  (list (first (lookup-inferior-packages inferior "emacs-no-x")))
  (specifications->packages
   (list "emacs-ace-window"
         "emacs-ansible-doc"
         "emacs-anzu"
         "emacs-avy"
         "emacs-beacon"
         "emacs-cape"
         "emacs-combobulate"
         "emacs-consult"
         "emacs-consult-yasnippet"
         "emacs-corfu"
         "emacs-corfu-terminal"
         "emacs-coterm"
         "emacs-crux"
         "emacs-detached"
         "emacs-diredfl"
         "emacs-docker"
         "emacs-docker-compose-mode"
         "emacs-dockerfile-mode"
         "emacs-dumb-jump"
         "emacs-eat"
         "emacs-eev"
         "emacs-elfeed"
         "emacs-elpa-mirror"
         "emacs-embark"
         "emacs-embark-consult"
         "emacs-engine-mode"
         "emacs-envrc"
         "emacs-erlang"
         "emacs-expreg"
         "emacs-forge"
         "emacs-gcmh"
         "emacs-geiser"
         "emacs-geiser-guile"
         "emacs-gist"
         "emacs-git-gutter"
         "emacs-git-link"
         "emacs-guix"
         "emacs-helpful"
         "emacs-hl-todo"
         "emacs-inspector"
         "emacs-isearch-mb"
         "emacs-magit"
         "emacs-magit-todos"
         "emacs-marginalia"
         "emacs-move-text"
         "emacs-multiple-cursors"
         "emacs-nginx-mode"
         "emacs-ob-compile"
         "emacs-orderless"
         "emacs-org-alert"
         "emacs-org-bullets"
         "emacs-pcmpl-args"
         "emacs-perspective"
         "emacs-pinentry"
         "emacs-project"
         "emacs-project-tasks"
         "emacs-rainbow-delimiters"
         "emacs-rainbow-mode"
         "emacs-rg"
         "emacs-shell-command+"
         "emacs-smartparens"
         "emacs-symbol-overlay"
         "emacs-terraform-mode"
         "emacs-vertico"
         "emacs-volatile-highlights"
         "emacs-vundo"
         "emacs-yaml-mode"
         "emacs-yasnippet"
         "emacs-yasnippet-snippets"
         "emacs-ztree"
         ;; libs
         "glibc-locales"
         "tree-sitter"
         "tree-sitter-bash"
         "tree-sitter-c"
         "tree-sitter-cpp"
         "tree-sitter-css"
         "tree-sitter-go"
         "tree-sitter-haskell"
         "tree-sitter-html"
         "tree-sitter-java"
         "tree-sitter-javascript"
         "tree-sitter-json"
         "tree-sitter-markdown"
         "tree-sitter-org"
         "tree-sitter-php"
         "tree-sitter-python"
         "tree-sitter-ruby"
         "tree-sitter-rust"
         "tree-sitter-scheme"
         "tree-sitter-typescript"
         ;; tools
         "direnv"
         "docker-cli"
         "docker-compose"
         "dtach"
         "ghcli"
         "jq"
         "make"
         "ripgrep"
         "rsync"
         "socat"
         "tmate"
         "zip"))))
