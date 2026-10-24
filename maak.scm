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
  #:use-module (ice-9 format)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 textual-ports)
  #:use-module (srfi srfi-1)
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

;; ====== Releases ======

;; The version is written by hand once, in src/ggg/version.scm: that is what
;; `ggg --version' prints and what default.nix reads while it evaluates the
;; derivation.  guix.scm cannot read a Scheme module, so it carries a copy, and
;; `release' rewrites that copy from the version file.
;;
;; The version is read from the working tree rather than from the running
;; library, so the task writes the checkout's version whether it is run by this
;; checkout's ggg or by one already installed.

(define version-source
  "src/ggg/version.scm")

;; Each site is a file and a regular expression matching one place in it where
;; the version is written, with the version itself as the first group.  Only
;; that group is replaced, so the surrounding layout, quoting and wording stay
;; the file's business rather than this list's.
(define version-sites
  '(("guix.scm" . "\\(version \"([0-9]+\\.[0-9]+\\.[0-9]+)\"")))

(define* (read-version #:optional (directory "."))
  "The version written in DIRECTORY's version source, as a string."
  (let* ((file (if (string=? directory ".")
                   version-source
                   (string-append directory "/" version-source)))
         (text (and (file-exists? file)
                    (call-with-input-file file get-string-all)))
         (found (and text
                     (string-match
                      "ggg-version[ \t\n]+\"([0-9]+\\.[0-9]+\\.[0-9]+)\""
                      text))))
    (unless found
      (error (format #f
                     "release: ~a does not define ggg-version as a version"
                     file)))
    (match:substring found 1)))

(define* (release #:optional (directory "."))
  "Write the version into every file that cannot read it from the module, then
commit and tag the release.

The version is written by hand once, in src/ggg/version.scm, which is what
`ggg --version' prints, what default.nix reads, and what `maak version' shows.
guix.scm carries a copy, and this task rewrites it from that file.

A release is then the whole ritual in one command: the copies are made to agree,
everything tracked that changed is committed as `chore: Release vX.Y.Z', and
that commit is tagged `vX.Y.Z'.  The commit is `git commit -am', so it takes
every tracked change in the tree rather than only the ones this task made;
commit anything unrelated first if it should not ride along.  A version whose
tag already exists is refused rather than committed again or retagged, and a
tree with nothing left to commit is tagged where it stands.

DIRECTORY is the checkout to work in, the current directory by default.

Render the badges first if the glyph files changed (`maak run', `maak gallery'),
so that the release commit carries the images it describes."
  (define repo
    (if (string=? directory ".") "." directory))

  (define (path file)
    (if (string=? directory ".")
        file
        (string-append directory "/" file)))

  (define (read-text file)
    (let ((full (path file)))
      (if (file-exists? full)
          (call-with-input-file full get-string-all)
          (error (format #f
                         "release: no ~a in ~a; name the checkout's root"
                         file directory)))))

  (define (write-text file text)
    (call-with-output-file (path file)
      (lambda (port) (display text port))))

  (define (sites-of file)
    (filter (lambda (site) (string=? (car site) file)) version-sites))

  (define (named-files)
    (fold (lambda (site files)
            (if (member (car site) files)
                files
                (append files (list (car site)))))
          '()
          version-sites))

  (define (rewrite text pattern version)
    "Return TEXT with the version PATTERN names replaced by VERSION."
    (regexp-substitute/global
     #f pattern text 'pre
     (lambda (match)
       (regexp-substitute/global #f "[0-9]+\\.[0-9]+\\.[0-9]+"
                                 (match:substring match 0)
                                 'pre version 'post))
     'post))

  (define (sync-file file version)
    "Write VERSION into FILE, and return whether it had to."
    (let* ((text (read-text file))
           (rewritten (fold (lambda (site text)
                              (rewrite text (cdr site) version))
                            text
                            (sites-of file))))
      (if (string=? text rewritten)
          #f
          (begin
            (write-text file rewritten)
            #t))))

  (define (sync-copies! version)
    "Write VERSION into every copy, and return the files that changed."
    (filter (lambda (file) (sync-file file version)) (named-files)))

  ;; ---- The commit and the tag --------------------------------------------
  ;;
  ;; git runs as a program with its arguments, never through a shell, and is
  ;; pointed at DIRECTORY with `-C' so a release of another checkout commits
  ;; there and not wherever maak was started from.

  (define (git . arguments)
    "Run git in the checkout, and return the exit code it ended with.

`system*' answers with the wait status rather than the exit code, so a command
that exited 1 reads as 256 and one that could not be started reads as #f; both
are turned into the number a shell would report here, 127 when git never ran."
    (let ((status (apply system* "git" "-C" repo arguments)))
      (or (and status (status:exit-val status)) 127)))

  (define (checkout?)
    "Return whether DIRECTORY is a git checkout."
    (file-exists? (path ".git")))

  (define (tag-exists? tag)
    "Return whether TAG is already a tag of the checkout."
    (zero? (git "rev-parse" "--verify" "--quiet"
                (string-append "refs/tags/" tag))))

  (define (changes-to-commit?)
    "Return whether anything tracked differs from the last commit."
    (case (git "diff" "--quiet" "HEAD")
      ((0) #f)
      ((1) #t)
      (else
       (error (format #f
                      "release: git could not compare ~a with a commit; is it a checkout with one?"
                      repo)))))

  (define (commit-release version)
    "Commit every tracked change as the release VERSION, and return the message."
    (let ((message (format #f "chore: Release v~a" version)))
      (unless (zero? (git "commit" "-am" message))
        (error "release: git commit failed, so nothing was tagged"))
      message))

  (define (tag-release version)
    "Tag the current commit as the release VERSION, and return the tag."
    (let ((tag (string-append "v" version)))
      (unless (zero? (git "tag" tag))
        (error (format #f
                       "release: `git tag ~a' failed; the release was committed, but not tagged"
                       tag)))
      tag))

  (let* ((version (read-version directory))
         (tag (string-append "v" version)))
    (unless (checkout?)
      (error (format #f
                     "release: ~a is not a git checkout, so there is nothing to commit or tag"
                     repo)))
    (when (tag-exists? tag)
      (error (format #f
                     "release: ~a is already released as ~a; bump ~a first"
                     version tag version-source)))
    (let ((changed (sync-copies! version)))
      (if (null? changed)
          (format #t "Every file that names the version already says ~a.~%" version)
          (for-each (lambda (file)
                      (format #t "Wrote ~a into ~a.~%" version file))
                    changed))
      (if (changes-to-commit?)
          (let ((message (commit-release version)))
            (tag-release version)
            (format #t "Committed `~a' and tagged ~a.~%" message tag))
          (begin
            (tag-release version)
            (format #t "Nothing to commit; tagged ~a at the current commit.~%"
                    tag))))))

;; ====== Maak tasks ======

(define (help)
  "Display program help screen."
  (time-machine-program-shell '("ggg --help")))

(define (default)
  "Default task to run, call program's help."
  (help))

(define (version)
  "Print ggg's version, as written in src/ggg/version.scm."
  (format #t "ggg ~a~%" (read-version)))

(define (fmt)
  "Format Scheme source code files according to the Guix style guide."
  ($ '("find . -maxdepth 8 -name '*.scm'" "-type f -exec guix style -f {} \\;")
     #:verbose? #t))

(define (repl)
  "Development REPL."
  (time-machine-manifest-shell '("guile -L ./src"
                    "-c '((@ (ares server) run-nrepl-server))'")))

(define (test)
  "Run ggg's test suite."
  (time-machine-manifest-shell '("guile -L ./src ./test/ggg-tests.scm")))

(define (write-gallery destination)
  "Write the HTML gallery of every badge in ./glyphs and every logo."
  (time-machine-program-shell (list (~ "ggg --gallery ~a" destination)
                                    "--glyphs ./glyphs")))

(define (gallery)
  "Generate the HTML gallery of every badge and logo."
  (write-gallery "./test/gallery.html"))

(define (docs)
  "Generate technical API documentation for Maak."
  (delete-file-recursively "doc")
  (time-machine-manifest-shell (list (~ "documenta api ./src/~a && " project-name)
                        (~ "texi2any -v --html --css-ref=~a" api-docs-css-url)
                        "./doc/api/index.texi"))
  (mv "./index" "./doc/api-dist"))

(define (deploy)
  (run)
  ;; The gallery ships with dist/ so the CI deployment publishes it:
  ;; https://jointhefreeworld.org/ggg/dist/gallery.html
  (write-gallery "./dist/gallery.html")
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
  (git-fetch "--all")
  (let* ((latest-tag (syscall-with-output "git describe --tags --abbrev=0")))
    ($ (list (~ "podman push localhost/~a:latest" project-name)
             (~ "docker.io/jjba23/~a:~a" project-name latest-tag))
       #:verbose? #t)))

(define (dev-run)
  (time-machine-manifest-shell '("guile -L ./src -c '((@(ggg main) main))'"
                    "--file /home/joe/Hacking/ggg/glyphs/jjba23.scm"
                    "--destination ./dist" "--resources ./resources")))

(define (run)
  "Generate every badge into ./dist, including the logo showcase."
  (time-machine-program-shell '("ggg --file ./glyphs/jjba23.scm" "--destination ./dist"))
  ;; ggg clears the destination directory, so the second file has to keep it.
  (time-machine-program-shell '("ggg --file ./glyphs/showcase.scm" "--destination ./dist"
                                "--keep")))

(define (run-convert)
  "Like run, but also write a PNG next to every SVG."
  (time-machine-program-shell '("ggg --file ./glyphs/jjba23.scm" "--destination ./dist"
                                "--convert"))
  (time-machine-program-shell '("ggg --file ./glyphs/showcase.scm" "--destination ./dist"
                                "--keep" "--convert")))

(define (showcase)
  "Generate only the badges of the popular-logo showcase into ./dist."
  (time-machine-program-shell '("ggg --file ./glyphs/showcase.scm" "--destination ./dist"
                                "--keep")))

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
