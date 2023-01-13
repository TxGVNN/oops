(define-module (my emacs)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages emacs-xyz)
  )

(define-public emacs-project
  (package
    (name "emacs-project")
    (version "0.9.4")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://elpa.gnu.org/packages/project-" version ".tar"))
       (sha256
        (base32 "10xmpx24k98crpddjdz1i4wck05kcnj3wdxhdj4km53nz8q66wbg"))))
    (build-system emacs-build-system)
    (propagated-inputs (list emacs-xref))
    (home-page "https://elpa.gnu.org/packages/project.html")
    (synopsis "Operations on the current project")
    (description
     "This library contains generic infrastructure for dealing with projects,
some utility functions, and commands using that infrastructure.")
    (license license:gpl3+)))
