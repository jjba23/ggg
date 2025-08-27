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

(define-module (maak)
  #:use-module (maak maak)
  #:declarative? #t)

;; ====== Maak constants ======

;; The absolute path to the directory where the main project files will be deployed.
(define deploy-dir
  "/srv/http/jointhefreeworld.org")

;; The absolute URL for the CSS stylesheet used to style API documentation.
(define api-docs-css-url
  "https://jointhefreeworld.org/static-assets/api-docs/css/style.css")

(define project-name
  'ggg)

;; ====== Maak tasks ======

(define (help)
  "Display program help screen."
  (program-shell '("ggg --help")))

(define (default)
  "Default task to run, call program's help."
  (help))

(define (fmt)
  "Format Scheme source code files according to the Guix style guide."
  ($ '("find . -maxdepth 8 -name '*.scm'" "-type f -exec guix style -f {} \\;")
     #:verbose? #t))

(define (repl)
  "Development REPL."
  (manifest-shell '("guile -L ./src"
                    "-c '((@ (ares server) run-nrepl-server))'")))

(define (docs)
  "Generate technical API documentation for Maak."
  (delete-file-recursively "doc")
  (manifest-shell (list (~ "documenta api ./src/~a && " project-name)
                        (~ "texi2any -v --html --css-ref=~a" api-docs-css-url)
                        "./doc/api/index.texi"))
  (mv "./index" "./doc/api-dist"))

(define (deploy)
  (run)
  (docs)
  ;; Deploy GGG
  (mkdir-p (~ "~a/ggg" deploy-dir))
  (delete-file-recursively (~ "~a/ggg/dist" deploy-dir))
  (mv "dist"
      (~ "~a/ggg/dist" deploy-dir))
  ;; Deploy API docs
  (remkdir-p (~ "~a/api-docs/maak" deploy-dir))
  (mv "doc/api-dist/*"
      (~ "~a/api-docs/maak" deploy-dir))
  (delete-file-recursively "doc"))

(define (package-docker)
  "Create a Docker image for GGG."
  ($ '("guix pack --file=./guix.scm" "--format=docker" "--image-tag=ggg"
       "-S /bin=bin" "bash coreutils util-linux-with-udev guile imagemagick")))

(define (dev-run)
  (manifest-shell '("guile -L ./src -c '((@(ggg main) main))'"
                    "--file ./glyphs/jjba23.scm" "--destination ./dist"
                    "--resources-dir ./resources")))

(define (run)
  (program-shell '("ggg --file ./glyphs/jjba23.scm" "--destination ./dist")))

(define (run-convert)
  (program-shell '("ggg --file ./glyphs/jjba23.scm" "--destination ./dist"
                   "--convert")))

(define (run-stdin)
  ($ '("cat ./glyphs/jjba23.scm |" "guix shell -f guix.scm --"
       "ggg -i -d ./dist")))

(define (run-stdout)
  (program-shell '("ggg --file ./glyphs/jjba23.scm --stdout")))

(define (run-stdin-stdout)
  ($ '("cat ./glyphs/jjba23.scm |" "guix shell -f guix.scm --" "ggg -i -o")))
