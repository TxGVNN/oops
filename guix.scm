(define-module (guix)
  #:use-module (guix git-download)
  #:use-module (guix build-system)
  #:use-module (guix build-system copy)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (gnu packages)
  #:use-module (guxti packages me)
  #:use-module ((guix licenses) #:prefix license:))

(define-public oops-next
  (package/inherit oops
    (name "oops-next")
    (version "pack")
    (source (local-file "." "oops-checkout" #:recursive? #t))))
