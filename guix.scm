;; ggg: guile glyph generator

;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; ggg is free software: you can redistribute it and/or modify
;; it under the terms of the GNU Affero General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; ggg is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU Affero General Public License for more details.

;; You should have received a copy of the GNU Affero General Public License
;; along with ggg.  If not, see <https://www.gnu.org/licenses/>.

(use-modules (guix gexp)
             (guix packages)
             (guix git-download)
             ((guix licenses)
              #:prefix license:)
             (guix build-system guile)
             ((guix build utils)
              #:select (with-directory-excursion ))
             (gnu packages)
             (gnu packages bash)
             (gnu packages guile)
             (gnu packages imagemagick)
             (gnu packages guile-xyz))

(define %source-dir
  (dirname (current-filename)))

(define-public ggg
  (package
    (name "ggg")
    (version "0.4.0")
    (source
     (local-file %source-dir
                 #:recursive? #t
                 #:select? (git-predicate %source-dir)))
    (arguments
     `(#:source-directory "src"
       #:phases (modify-phases %standard-phases
                  (add-before 'build 'install-program-files
                    (lambda* (#:key outputs #:allow-other-keys)
                      (let ((bin (string-append (assoc-ref outputs "out")
                                                "/bin"))
                            (share (string-append (assoc-ref outputs "out")
                                                  "/share")))
                        (mkdir-p (string-append share "/scripts"))
                        (mkdir-p (string-append share "/resources"))
                        (install-file "resources/help.txt"
                                      (string-append share "/resources"))
                        (copy-recursively "resources/svg-paths"
                                          (string-append share
                                           "/resources/svg-paths"))
                        (install-file "scripts/ggg" bin)
                        (install-file "scripts/log.bash"
                                      (string-append share "/scripts/"))
                        (chmod (string-append bin "/ggg") #o755)))))))
    (build-system guile-build-system)
    (native-inputs (list guile-3.0))
    (inputs (list guile-3.0 bash-minimal))
    (propagated-inputs (list imagemagick))
    (synopsis "GGG is a SVG image generator for project and web badges")
    (description
     "GGG (Guile Glyph Generator) is a command-line utility
that allows you to generate pretty images/badges which can be used for
your projects, announcing tech used, sponsoring and appreciating
other projects, distinguishing versions of things supported, etc.

GGG is highly configurable, reads Scheme files where you define your tasks,
and supports badges between one and three parts.  It leverages SVG generation
from Lisp and S-expressions, building pixel perfect badges.")
    (home-page "https://codeberg.org/jjba23/ggg")
    (license license:agpl3+)))

ggg
