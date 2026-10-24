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
  ;; The git and container helpers are imported under prefixes because this file
  ;; names a task `run', which hides the runner of that name, and because a
  ;; release's git is the library's rather than a task of this file.
  #:use-module ((maak git) #:prefix git:)
  #:use-module ((maak container) #:prefix ct:)
  #:use-module (ice-9 regex)
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
                   (~ "~a/~a" directory version-source)))
         (text (if (file-exists? file) (read-file file) #f))
         (found (and text
                     (string-match
                      "ggg-version[ \t\n]+\"([0-9]+\\.[0-9]+\\.[0-9]+)\""
                      text))))
    (unless found
      (task-error "release: ~a does not define ggg-version as a version"
                  #:args (list file)
                  #:hint "Write (define ggg-version \"X.Y.Z\") in it."))
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
        (~ "~a/~a" directory file)))

  (define (read-text file)
    (let ((full (path file)))
      (if (file-exists? full)
          (read-file full)
          (task-error "release: no ~a in ~a; name the checkout's root"
                      #:args (list file directory)
                      #:hint "Name the checkout's root as DIRECTORY."))))

  (define (write-text file text)
    (write-file (path file) text))

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
  ;; The library wrappers take `#:directory', so a release of another checkout
  ;; commits there rather than wherever maak was started from.

  (define (checkout?)
    "Return whether DIRECTORY is a git checkout."
    (file-exists? (path ".git")))

  (define (tag-exists? tag)
    "Return whether TAG is already a tag of the checkout."
    (member tag (git:git-tags #:directory repo)))

  (define (changes-to-commit?)
    "Return whether anything tracked differs from the last commit."
    (not (string=? ""
                   (string-trim-both
                    (git:git-output (list "diff" "--name-only" "HEAD")
                                    #:directory repo)))))

  (define (commit-release version)
    "Commit every tracked change as the release VERSION, and return the message."
    (let ((message (~ "chore: Release v~a" version)))
      (unless (git:git (list "commit" "--all" "-m" message)
                       #:directory repo #:allow-failure? #t)
        (task-error "release: git commit failed, so nothing was tagged"
                    #:hint "Commit or stash what git refuses, then run it again."))
      message))

  (define (tag-release version)
    "Tag the current commit as the release VERSION, and return the tag."
    (let ((tag (~ "v~a" version)))
      (unless (git:git (list "tag" tag)
                       #:directory repo #:allow-failure? #t)
        (task-error "release: `git tag ~a' failed; the release was committed, but not tagged"
                    #:args (list tag)
                    #:hint "Tag the release by hand once the reason is fixed."))
      tag))

  (let* ((version (read-version directory))
         (tag (~ "v~a" version)))
    (unless (checkout?)
      (task-error "release: ~a is not a git checkout, so there is nothing to commit or tag"
                  #:args (list repo)
                  #:hint "Run it inside a checkout, or name one as DIRECTORY."))
    (when (tag-exists? tag)
      (task-error "release: ~a is already released as ~a; bump ~a first"
                  #:args (list version tag version-source)
                  #:hint "Write the next version into that file."))
    (let ((changed (sync-copies! version)))
      (if (null? changed)
          (log-info "Every file that names the version already says ~a." version)
          (for-each (lambda (file)
                      (log-info "Wrote ~a into ~a." version file))
                    changed))
      (if (changes-to-commit?)
          (let ((message (commit-release version)))
            (tag-release version)
            (log-info "Committed `~a' and tagged ~a." message tag))
          (begin
            (tag-release version)
            (log-info "Nothing to commit; tagged ~a at the current commit." tag))))))

;; ====== Maak tasks ======

(define (help)
  "Display program help screen."
  (time-machine-program-shell (list "ggg" "--help")))

(define (default)
  "Default task to run, call program's help."
  (help))

(define (version)
  "Print ggg's version, as written in src/ggg/version.scm."
  (log-info "ggg ~a" (read-version)))

(define (fmt)
  "Format Scheme source code files according to the Guix style guide."
  ;; `run' names a task of this file, so the library's runner is named in full
  ;; rather than called through the binding the task replaced.
  ((@ (maak maak) run)
   (list "find" "." "-maxdepth" "8" "-name" "*.scm" "-type" "f"
         "-exec" "guix" "style" "-f" "{}" ";")
   #:verbose? #t))

(define (repl)
  "Development REPL."
  (time-machine-manifest-shell
   (list "guile" "-L" "./src"
         "-c" "'((@ (ares server) run-nrepl-server))'")))

(define (test)
  "Run ggg's test suite."
  (time-machine-manifest-shell (list "guile" "-L" "./src"
                                     "./test/ggg-tests.scm")))

(define (write-gallery destination)
  "Write the HTML gallery of every badge in ./glyphs and every logo."
  (time-machine-program-shell (list "ggg" "--gallery" destination
                                    "--glyphs" "./glyphs")))

(define (gallery)
  "Generate the HTML gallery of every badge and logo."
  (write-gallery "./test/gallery.html"))

(define (docs)
  "Generate technical API documentation for Maak."
  (delete-file-recursively "doc")
  ;; Two calls rather than one `&&': each step fails where it happens, and the
  ;; documentation of the API is written before the manual page is built.
  (time-machine-manifest-shell
   (list "documenta" "api" (~ "./src/~a" project-name)))
  (time-machine-manifest-shell
   (list "texi2any" "-v" "--html"
         (~ "--css-ref=~a" api-docs-css-url)
         "./doc/api/index.texi"))
  (mv "./index" "./doc/api-dist"))

(define (deploy)
  ;; `run' here is this file's badge task, not the library's runner: the badges
  ;; are rendered again so the gallery and the `dist/' that ships are the ones
  ;; the current glyphs describe.
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
      (~ "~a/api-docs/~a" deploy-dir project-name)
      #:expand? #t)
  (delete-file-recursively "doc"))

(define (package-docker)
  "Build the Docker image for GGG."
  (guix-pack '()
             #:format "docker"
             #:image-tag "ggg"
             #:symlinks '("/bin=bin")
             #:extra-packages '("bash" "coreutils" "util-linux-with-udev"
                                "guile" "imagemagick")
             #:verbose? #t))

(define (push-docker-latest)
  "Push the latest locally generated Docker image to Dockerhub."
  (ct:container (list "push"
                      (~ "localhost/~a:latest" project-name)
                      (~ "docker.io/jjba23/~a:latest" project-name))
                #:verbose? #t))

(define (push-docker-tag)
  "Push the locally generated Docker image to Dockerhub."
  (git:git-fetch "--all")
  (let ((latest-tag (git:git-describe-tag)))
    (ct:container (list "push"
                        (~ "localhost/~a:latest" project-name)
                        (~ "docker.io/jjba23/~a:~a" project-name latest-tag))
                  #:verbose? #t)))

(define (dev-run)
  (time-machine-manifest-shell
   (list "guile" "-L" "./src" "-c" "'((@(ggg main) main))'"
         "--file" "/home/joe/Hacking/ggg/glyphs/jjba23.scm"
         "--destination" "./dist"
         "--resources" "./resources")))

(define (run)
  "Generate every badge into ./dist, including the logo showcase."
  (time-machine-program-shell (list "ggg" "--file" "./glyphs/jjba23.scm"
                                    "--destination" "./dist"))
  ;; ggg clears the destination directory, so the second file has to keep it.
  (time-machine-program-shell (list "ggg" "--file" "./glyphs/showcase.scm"
                                    "--destination" "./dist" "--keep")))

(define (run-convert)
  "Like run, but also write a PNG next to every SVG."
  (time-machine-program-shell (list "ggg" "--file" "./glyphs/jjba23.scm"
                                    "--destination" "./dist" "--convert"))
  (time-machine-program-shell (list "ggg" "--file" "./glyphs/showcase.scm"
                                    "--destination" "./dist" "--keep" "--convert")))

(define (showcase)
  "Generate only the badges of the popular-logo showcase into ./dist."
  (time-machine-program-shell (list "ggg" "--file" "./glyphs/showcase.scm"
                                    "--destination" "./dist" "--keep")))

(define (run-stdin)
  ;; A pipe, without a shell: the file is fed to ggg in the project's Guix
  ;; environment.
  (run-pipeline (list (list "cat" "./glyphs/jjba23.scm")
                      (list "guix" "shell" "-f" "guix.scm" "--"
                            "ggg" "-i" "-d" "./dist"))))

(define (run-stdout)
  (time-machine-program-shell (list "ggg" "--file" "./glyphs/jjba23.scm"
                                    "--stdout")))

(define (run-stdin-stdout)
  (run-pipeline (list (list "cat" "./glyphs/jjba23.scm")
                      (list "guix" "shell" "-f" "guix.scm" "--"
                            "ggg" "-i" "-o"))))

(define (hot-reload)
  "Hot-reloading developer's setup."
  (time-machine-manifest-shell (list "watchexec"
                                     "--clear"
                                     (~ "--exts ~a"
                                        (string-join (map symbol->string
                                                      hot-reload-file-types)
                                                     ","))
                                     "--on-busy-update=restart"
                                     "--shell" "bash"
                                     "--watch" "." "--"
                                     "maak" "run")))

(define (hr)
  (hot-reload))

(define (dev)
  (hot-reload))
