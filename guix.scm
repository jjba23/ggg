(use-modules (guix gexp)
             (guix packages)
             (guix git-download)
             ((guix licenses)
              #:prefix license:)
             (guix build-system guile)
             ((guix build utils)
              #:select (with-directory-excursion ))
             (gnu packages)
             (gnu packages guile)
             (gnu packages guile-xyz))

(define %source-dir
  (dirname (current-filename)))

(package
  (name "ggg")
  (version "0.2.8")
  (source
   (local-file %source-dir
               #:recursive? #t
               #:select? (git-predicate %source-dir)))
  (arguments
   `(#:source-directory "src"
     #:phases (modify-phases %standard-phases
                (add-before 'build 'remove-guix.scm
                  (lambda _
                    (delete-file "guix.scm")))
                (add-before 'build 'install-program-files
                  (lambda* (#:key outputs #:allow-other-keys)
                    (let ((bin (string-append (assoc-ref outputs "out") "/bin"))
                          (share (string-append (assoc-ref outputs "out")
                                                "/share")))
                      (mkdir-p (string-append share "/scripts"))
                      (mkdir-p (string-append share "/resources"))
                      (install-file "resources/help.txt"
                                    (string-append share "/resources/help.txt"))
                      (copy-recursively "resources/svg-paths"
                                        (string-append share "/resources/svg-paths"))
                      (install-file "scripts/ggg" bin)
                      (install-file "scripts/log.sh"
                                    (string-append share "/scripts/"))
                      (chmod (string-append bin "/ggg") #o755)))))))
  (build-system guile-build-system)
  (native-inputs (list guile-next))
  (inputs (list guile-next))
  (synopsis
   "Generate SVG images, Org/Markdown badges and more, from Guile Scheme")
  (description
   "Be proud and appreciate technologies and techniques you use, distinguish
clearly supported versions of things, etc. with flexible support for
badges between one and three parts. Through SVG generation from Lisp and S-expressions
we leverage a beautiful DSL and apply some mathematical knowledge to build pixel perfect badges.
These SVG can then be easily converted without quality loss to any desired format.")
  (home-page "https://codeberg.org/jjba23/ggg")
  (license license:lgpl3+))

