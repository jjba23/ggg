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
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 popen)
  #:declarative? #t)

;; ====== Maak constants ======

;; The path to the directory where the main project files will be deployed.
(define deploy-dir
  "/srv/http/jointhefreeworld.org")

;; The URL for the CSS stylesheet used to style API documentation.
(define api-docs-css-url
  "https://jointhefreeworld.org/static/css/jointhefreeworld.css")

(define project-name
  'ggg)

(define hot-reload-file-types
  '(scm))

;; ====== Maak abstractions ======

(define (syscall-with-output cmd)
  (let* ((process (open-input-pipe cmd))
         (process-output (get-string-all process)))
    (close-pipe process) process-output))

;; ====== Maak tasks ======

(define (help)
  "Display program help screen."
  (time-machine-program-shell '("ggg --help")))

(define (default)
  "Default task to run, call program's help."
  (help))

(define (fmt)
  "Format Scheme source code files according to the Guix style guide."
  ($ '("find . -maxdepth 8 -name '*.scm'" "-type f -exec guix style -f {} \\;")
     #:verbose? #t))

(define (repl)
  "Development REPL."
  (time-machine-manifest-shell '("guile -L ./src"
                    "-c '((@ (ares server) run-nrepl-server))'")))

(define (docs)
  "Generate technical API documentation for Maak."
  (delete-file-recursively "doc")
  (time-machine-manifest-shell (list (~ "documenta api ./src/~a && " project-name)
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
  (remkdir-p (~ "~a/api-docs/~a" deploy-dir project-name))
  (mv "doc/api-dist/*"
      (~ "~a/api-docs/~a" deploy-dir project-name))
  (delete-file-recursively "doc"))

(define (package-docker)
  "Create a Docker image for GGG."
  ($ '("guix pack --file=./guix.scm" "--format=docker" "--image-tag=ggg"
       "-S /bin=bin" "bash coreutils util-linux-with-udev guile imagemagick")
     #:verbose? #t))

(define (push-docker-latest)
  "Push the latest locally generated Docker image to Dockerhub."
  ($ (list (~ "podman push localhost/~a:latest" project-name)
           (~ "docker.io/jjba23/~a:latest" project-name))
     #:verbose? #t))

(define (push-docker-tag)
  "Push the locally generated Docker image to Dockerhub."
  ($ '("git fetch --all"))
  (let* ((latest-tag (syscall-with-output "git describe --tags --abbrev=0")))
    ($ (list (~ "podman push localhost/~a:latest" project-name)
             (~ "docker.io/jjba23/~a:~a" project-name latest-tag))
       #:verbose? #t)))

(define (dev-run)
  (time-machine-manifest-shell '("guile -L ./src -c '((@(ggg main) main))'"
                    "--file /home/joe/Hacking/ggg/glyphs/jjba23.scm"
                    "--destination ./dist" "--resources ./resources")))

(define (run)
  (time-machine-program-shell '("ggg --file ./glyphs/jjba23.scm" "--destination ./dist")))

(define (run-convert)
  (time-machine-program-shell '("ggg --file ./glyphs/jjba23.scm" "--destination ./dist"
                   "--convert")))

(define (run-stdin)
  ($ '("cat ./glyphs/jjba23.scm |" "guix shell -f guix.scm --"
       "ggg -i -d ./dist")))

(define (run-stdout)
  (time-machine-program-shell '("ggg --file ./glyphs/jjba23.scm --stdout")))

(define (run-stdin-stdout)
  ($ '("cat ./glyphs/jjba23.scm |" "guix shell -f guix.scm --" "ggg -i -o")))

(define (hot-reload)
  "Hot-reloading developer's setup."
  (time-machine-manifest-shell (list "watchexec"
                                     "--clear"
                                     (~ "--exts ~a"
                                        (string-join (map symbol->string
                                                      hot-reload-file-types)
                                                     ","))
                                     "--on-busy-update=restart"
                                     "--shell bash"
                                     "--watch . --"
                                     "maak run")))

(define (hr)
  (hot-reload))

(define (dev)
  (hot-reload))
