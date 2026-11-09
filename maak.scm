;; ggg: guile glyph generator
;;
;; Spdx-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (maak)
  #:use-module (maak maak)
  #:use-module ((ice-9 rdelim) #:select (read-line))
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

;; The port the deployment's nginx proxies to: ggg.jointhefreeworld.org
;; reaches this server through the ggg-proxy upstream in the wolk-jjba
;; repository's src/wolk-jjba/nginx.scm, so the two numbers move together.
(define server-port
  "50055")

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

(define (production-server)
  "Run the badge server the way the deployment starts it: on loopback, on
the port nginx proxies.

The wolk-jjba server starts this task from the checkout, so pulling there
and restarting its Shepherd service runs the pulled code.  The logos come
from the package this task builds out of the checkout, so they are the
checkout's logos without naming a directory."
  (time-machine-program-shell (list "ggg" "--serve"
                                    "--host" "127.0.0.1"
                                    "--port" server-port)))

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

;; ====== Agent skills ======

;; `run' names a task in this file, so the shell helper is reached through the
;; module it comes from.

;; AGENTS.md is generated, never edited by hand.  The section has two halves:
;; the data below, which is this project's, and the task itself, which is not.
;; Another repository copies the whole section and replaces the data - the
;; header, the pinned skills (repository, commit, path, licence) and the
;; practices - and `maak agents' writes its own AGENTS.md.  Regeneration is
;; deterministic: the same pins and the same text produce the same file, byte
;; for byte, and it needs nothing but curl.  The skill URLs assume GitHub, so a
;; skill hosted elsewhere needs a URL of its own.

(define ponytail-commit
  "96608e078b2d5ea607c5c3b8b5a54d1c1fba6846")

(define tdd-commit
  "22f0b463e7a5e579904dd6211a520321035526f7")

;; Name, repository, commit, the path the repository keeps the skill at and the
;; licence.  A skill arrives whole: trimming it means scanning for headings, and
;; such a scan cannot tell a heading from a `##' line inside a code fence.
(define agent-skills
  (list (list "ponytail"
              "DietrichGebert/ponytail"
              ponytail-commit
              "skills/ponytail/SKILL.md"
              "MIT")
        (list "test-driven-development"
              "obra/superpowers"
              tdd-commit
              "skills/test-driven-development/SKILL.md"
              "MIT")))

(define agent-skills-dir
  "reports/agent-skills")

(define agents-header
  "# AGENTS.md

Generated by `maak agents` from the pinned skills and the practices in
`maak.scm`; edit that task, never this file.  The pins and the text are the whole
input, so regenerating gives the same document.  The repository's own rules win
over general advice, and the narrowest rule here wins over the broadest.
")

;; Practices this project keeps.  They are short on purpose: a rule a reader
;; checks in a second is a rule that gets followed.  The pinned skills are the
;; long form of the same habits.
(define agent-practices
  (list
   "## Documentation

- Every user-visible change reaches the documentation: the page that owns the
  feature, the manual page for a flag or an environment variable, and the
  release notes under the unreleased heading.
- Keep the table of contents in step with the headings.  A section with no entry
  is a section nobody finds.
- The guide is Org: one `*` heading per page, `**` for sections, `#+TITLE` and
  `#+EMAIL` at the top, a `CUSTOM_ID` on anything linked from elsewhere, and
  `file:` links between pages.
- Explain why and when, never what: the code already says what.  A docstring's
  first line works as a summary on its own.
- Spell an identifier the way the code spells it - the exact name, not a
  description of it.
- An example must run as written, copied from a real invocation.
- No promises about the future and no changelog in the guide; history lives in
  the release notes.
"
   "## Security

- No secrets in the tree.  Tokens, keys and passwords arrive through the
  environment, and no recipe, workflow or example embeds one.
- Validate at the edge: anything from a file, a report, a path or a subprocess
  is untrusted until it has been checked.
- Never build a shell string out of data.  Tasks pass argument lists, and Guile
  calls `(system \"program\" \"arg\")` or `open-pipe*`, never a command
  assembled with `string-append`.
- Do not `eval` or `read` input you did not write; parse with `(json)` or a
  reader built for the format.
- Escape what leaves the process: a name that came from input is escaped when
  it is written to XML, HTML or a data file.
- Fail closed.  A file that cannot be read is an error, not an empty result.
- Input never chooses the path of a written file; writes stay inside the
  directory reserved for them.
- A dependency is a security decision: it must be needed, MIT compatible and
  pinned.
- Report a vulnerability privately, not in a public issue.
"
   "## Performance

- Measure first.  A before and after belongs in the benchmark, and a speedup
  claimed without a number is not a speedup.
- Prefer not doing the work: cache it, skip it, batch it, or delete the call,
  before making the call faster.
- Then the algorithm, then the data structure (hash table, vector), then the
  micro-optimisation.  In that order, for that reason.
- Guile specifics: keep module resolution and long `assoc` chains out of loops,
  use `#:declarative?` modules and compiled `.go` files at startup, and reach
  for `statprof` instead of guessing where the time goes.
- A shortcut that buys speed costs clarity; it gets a measurement and a
  `shortcut:` comment saying what it costs and when to revisit it.
- Coverage instrumentation is slow by design: iterate without it, and measure
  before finishing.
"
   "## Architecture decisions

- A decision that is expensive to reverse gets a short record: the context, the
  decision, the consequences, and the alternatives that lost.  A small decision
  belongs in the commit body instead.
- Two paragraphs beat a design document; record the choice while it is still a
  choice, not after it has become a fact.
- An accepted record is not rewritten.  Supersede it with a new one and link the
  two directions.
- The record lives next to its subject: the documentation for anything a user
  would notice, the release notes for the release-level result.
- Changes to the public API, a file format, the pipeline or the licence get this
  treatment at a minimum in the commit body.
"
   "## Semantic versioning

- The project follows SemVer 2.0.0 for its public API: the exported functions,
  the CLI flags and environment variables, and the shape of its file formats.
- A breaking change bumps MAJOR, a new feature MINOR, a fix PATCH.  A new export
  is MINOR; removing or changing one is MAJOR.
- One version string, named everywhere it appears: the source, the build
  recipes, the manual page and the packaging.
- A release is a dated release-notes section, an annotated `vX.Y.Z` tag on the
  release commit, and a packaging checksum updated afterwards from the published
  archive.
"
   "## Conventional commits

- `type(scope): summary`, imperative, lower case, no full stop, about seventy
  characters.
- Types in use: `feat`, `fix`, `perf`, `refactor`, `test`, `docs`, `build`, `ci`,
  `chore`.  A `!` after the type or a `BREAKING CHANGE:` footer marks a MAJOR
  change, and says what breaks.
- The subject says what changed.  The body says why, and what was rejected.
- One logical change per commit: a refactor and a fix travel apart, so either
  can be reverted alone.
- Run the full validation task before committing, and never commit a red suite
  without saying so in the message.
- Reference the issue in the footer - `Closes #12` - not in the subject.
"
   "## Functional programming and immutability

- Pure functions in the core, effects at the edges.  Whatever touches the file
  system or the clock sits at the edge; the core does not.
- Prefer `let` and new values to `set!`.  Build results with `map`, `filter`,
  `fold` and named `let`, not with index loops that push into a list.
- A record is a value: construct a new one instead of mutating a shared one, and
  pass configuration as arguments or parameters rather than as globals.
- Handle an exception at the boundary: catch it there, turn it into a result
  record, and let the caller decide what it means.
- A function that both computes and prints is two functions.
- Temporary effects - a changed directory, a bound environment variable - go
  through `dynamic-wind`.
- Prefer the expression style: `if` and `cond` that return a value, not a branch
  that assigns one.
"
   "## Do not reinvent the wheel

- Guile's standard library first: `(ice-9 ...)` for the runtime, `(srfi srfi-1)`
  for lists, `(srfi srfi-9)` for records, `(srfi srfi-13)` for strings, `(json)`
  for JSON.  The project already depends on all of them.
- Then this codebase: read the existing modules before writing a helper, and use
  the one that is nearly right instead of adding a second one.
- A new dependency needs a reason the standard library cannot meet, a licence
  the project can carry, and a paragraph in the commit body.
- Prefer deleting a special case to writing code that handles it.
- The best diff removes lines and keeps the behaviour; the second best is a
  small diff that is obvious a year later.
"))

(define (slurp path)
  "Return the whole of @var{path} as a string."
  (call-with-input-file path
    (lambda (port)
      (let loop ((lines '())
                 (line (read-line port)))
        (if (eof-object? line)
            (string-concatenate-reverse lines)
            (loop (cons (string-append line "\n") lines)
                  (read-line port)))))))

(define (fetch-skill name repository commit path)
  "Download one skill pinned at @var{commit}, into the reports tree.

  Returns the skill's text."
  (let ((target (~ "~a/~a.md" agent-skills-dir name))
        (url (~ "https://raw.githubusercontent.com/~a/~a/~a"
                repository commit path)))
    ((@ (maak maak) run) (list "curl" "--fail" "--silent" "--show-error" "--location"
               "--output" target url)
         #:verbose? #t)
    (slurp target)))

(define (agents)
  "Regenerate AGENTS.md from the pinned skills and the practices."
  ((@ (maak maak) run) (list "mkdir" "-p" agent-skills-dir))
  ;; Every download happens before the file is opened, so a fetch that fails
  ;; leaves the previous AGENTS.md in place rather than a half-written one.
  (let ((skills (map (lambda (skill)
                       (append skill
                               (list (fetch-skill (list-ref skill 0)
                                                  (list-ref skill 1)
                                                  (list-ref skill 2)
                                                  (list-ref skill 3)))))
                     agent-skills)))
    (call-with-output-file "AGENTS.md"
      (lambda (port)
        (display agents-header port)
        (for-each (lambda (skill)
                    (format port
                            "~%## ~a~%~%`~a` at `~a`, `~a`, ~a licensed.~%~%"
                            (list-ref skill 0)
                            (list-ref skill 1)
                            (list-ref skill 2)
                            (list-ref skill 3)
                            (list-ref skill 4))
                    (display (list-ref skill 5) port))
                  skills)
        (for-each (lambda (practice)
                    (newline port)
                    (display practice port))
                  agent-practices)))))
