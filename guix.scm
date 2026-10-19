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
             (gnu packages base)
             (gnu packages guile)
             (gnu packages imagemagick)
             (gnu packages guile-xyz)
             (gnu packages linux))

(define %source-dir
  (dirname (current-filename)))

(define-public ggg
  (package
    (name "ggg")
    (version "0.11.0")
    (source
     (local-file %source-dir
                 #:recursive? #t
                 #:select? (git-predicate %source-dir)))
    (build-system guile-build-system)
    (arguments
     (list
      #:source-directory "src"
      #:modules '((guix build guile-build-system)
                  (guix build utils)
                  (ice-9 match))
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'build 'install-program-files
            (lambda _
              (let ((bin (string-append #$output "/bin"))
                    (share (string-append #$output "/share")))
                (install-file "resources/help.txt"
                              (string-append share "/resources"))
                (copy-recursively "resources/logos"
                                  (string-append share "/resources/logos"))
                (install-file "scripts/ggg" bin)
                (chmod (string-append bin "/ggg") #o755))))
          (add-after 'unpack 'fix-paths
            (lambda* (#:key inputs #:allow-other-keys)
              (for-each (match-lambda
                          ((pattern program format-string)
                           (substitute* "scripts/ggg"
                             ((pattern)
                              (format #f format-string
                                      (search-input-file inputs
                                                         (string-append "bin/"
                                                          program)))))))
                        '(("readlink -f " "readlink" "~s -f ")
                          ("realpath " "realpath" "~s ")
                          ("dirname " "dirname" "~s ")
                          ("getopt " "getopt" "~s ")
                          ("exec guile " "guile" "exec ~s ")))
              (for-each (match-lambda
                          ((pattern program format-string)
                           (substitute* "src/ggg/main.scm"
                             ((pattern)
                              (format #f format-string
                                      (search-input-file inputs
                                                         (string-append "bin/"
                                                          program)))))))
                        '(("\"convert\"" "convert" "~s"))))))))
    (inputs (list guile-3.0 bash-minimal imagemagick coreutils-minimal util-linux))
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
