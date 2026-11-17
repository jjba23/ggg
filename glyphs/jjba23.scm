;; ggg: guile glyph generator
;;
;; Spdx-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; Commentary:
;;
;; The badges below pair a dark Catppuccin latte label with the pastel accents of
;; Catppuccin mocha, whose colors ggg knows by name: every color of every
;; supported theme is available as "<theme>-<color>". The label side (the one
;; holding the logo) is the darker `catppuccin-latte-subtext1' gray with
;; `catppuccin-latte-base' text (5.5:1), so the white logos stand out. Every
;; accent is a pastel mocha color with the dark `catppuccin-mocha-base' ink,
;; which keeps each second section at 7:1 or better while staying soft and warm.
;;
;; Hues follow the projects: Java, Scala, Redis, Maven and Jest stay red, Scheme
;; and Guile are orange (peach), Guix, Homebrew and Prettier are yellow, the
;; licenses are blue, Go and pytest are sky, Rust and Cargo are orange, Emacs is
;; pink, and so on. The accents lean warm: warm neutrals for the licenses and
;; docs, a peach for planning, a yellow for testing, while badges that stand for
;; a brand keep that brand's hue.
;;
;; The Rust family keeps the one peach: `rust-185+', the edition and the cargo
;; subcommands all wear it, so a reader sees Rust at a glance and reads the
;; second word for the detail -- except `cargo-clippy' and `cargo-fmt', which
;; join the lavender lint and yellow format families they belong to. The tools
;; the rest of the checkouts in this tree tick off follow the same rule: the
;; TypeScript, React, Vite and Ninja badges of a Vite dashboard, the Actions and
;; Woodpecker CI badges, and the Shepherd, Podman, Caddy, Prometheus, Grafana,
;; JSON, YAML, Wayland and JUnit badges take the hue of the thing they name.
;;
;; Every badge is declared once, at the end of this file, and rendered twice:
;; in crystal glass under its plain id -- the set a project links to -- and in
;; the subtle `shadow' finish under a `showcase-' id, which keeps the look the
;; set shipped with before the glass. The `Crystal glass, in the other palettes'
;; group adds eight badges in the Doom, Dracula, Solarized and Modus palettes,
;; four of them in the monospace variant.
;;
;; `ggg --list-colors` prints every theme and color; see the README for the
;; other palettes.

(define-module (ggg config)
  #:declarative? #t)

(define glyph-pipeline-succeeded
  `((sections ((background . catppuccin-latte-subtext1) (text . "pipeline")
               (color . catppuccin-latte-base))
              ((background . catppuccin-mocha-green) (text . "succeeded")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . pipeline-succeeded)))

(define glyph-gnu-guix
  `((sections ((background . catppuccin-latte-subtext1) (text . "GNU")
               (color . catppuccin-latte-base)
               (logo . gnu))
              ((background . catppuccin-mocha-yellow) (text . "Guix")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . gnu-guix)))

(define glyph-scheme-guile
  `((sections ((background . catppuccin-latte-subtext1) (text . "Scheme")
               (color . catppuccin-latte-base)
               (logo . lambda))
              ((background . catppuccin-mocha-peach) (text . "Guile")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . scheme-guile)))

(define glyph-haskell-ghc910
  `((sections ((background . catppuccin-latte-subtext1)
               (text . "Haskell")
               (color . catppuccin-latte-base)
               (logo . lambda))
              ((background . catppuccin-mocha-mauve) (text . "GHC 9.10")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . haskell-ghc910)))

(define glyph-gnu-make
  `((sections ((background . catppuccin-latte-subtext1) (text . "GNU")
               (color . catppuccin-latte-base)
               (logo . gnu))
              ((background . catppuccin-mocha-red) (text . "Make")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . gnu-make)))

(define glyph-maak
  `((sections ((background . catppuccin-latte-subtext1) (text . "maak")
               (color . catppuccin-latte-base)
               (logo . maak))
              ((background . catppuccin-mocha-peach) (text . "tasks")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . maak)))

(define glyph-byggsteg
  `((sections ((background . catppuccin-latte-subtext1) (text . "byggsteg")
               (color . catppuccin-latte-base)
               (logo . byggsteg))
              ((background . catppuccin-mocha-green) (text . "CI/CD")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . byggsteg)))

(define glyph-byggsteg-github
  `((sections ((background . catppuccin-latte-subtext1) (text . "byggsteg")
               (color . catppuccin-latte-base)
               (logo . byggsteg))
              ((background . catppuccin-mocha-overlay2) (text . "GitHub")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . byggsteg-github)))

(define glyph-github-mirror
  `((sections ((background . catppuccin-latte-subtext1) (text . "GitHub")
               (color . catppuccin-latte-base)
               (logo . github))
              ((background . catppuccin-mocha-overlay2) (text . "mirror")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . github-mirror)))

(define glyph-lucidplan
  `((sections ((background . catppuccin-latte-subtext1) (text . "LucidPlan")
               (color . catppuccin-latte-base)
               (logo . lucidplan))
              ((background . catppuccin-mocha-peach) (text . "planning")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . lucidplan)))

(define glyph-bewaking
  `((sections ((background . catppuccin-latte-subtext1) (text . "bewaking")
               (color . catppuccin-latte-base)
               (logo . bewaking))
              ((background . catppuccin-mocha-maroon) (text . "security")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . bewaking)))

(define glyph-hygguile
  `((sections ((background . catppuccin-latte-subtext1) (text . "Hygguile")
               (color . catppuccin-latte-base)
               (logo . hygguile))
              ((background . catppuccin-mocha-rosewater) (text . "UI")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . hygguile)))

(define glyph-veritas
  `((sections ((background . catppuccin-latte-subtext1) (text . "Veritas")
               (color . catppuccin-latte-base)
               (logo . veritas))
              ((background . catppuccin-mocha-yellow) (text . "testing")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . veritas)))

(define glyph-symbanta
  `((sections ((background . catppuccin-latte-subtext1) (text . "Symbanta")
               (color . catppuccin-latte-base)
               (logo . symbanta))
              ((background . catppuccin-mocha-pink) (text . "analytics")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . symbanta)))

(define glyph-i18n-gnu-gettext
  `((sections ((background . catppuccin-latte-subtext1) (text . "i18n")
               (color . catppuccin-latte-base)
               (logo . language))
              ((background . catppuccin-mocha-red) (text . "GNU gettext")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . i18n-gnu-gettext)))

(define glyph-gnu-emacs
  `((sections ((background . catppuccin-latte-subtext1) (text . "GNU")
               (color . catppuccin-latte-base)
               (logo . emacs))
              ((background . catppuccin-mocha-pink) (text . "Emacs")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . gnu-emacs)))

(define glyph-gnu-emacs-single
  `((sections ((background . catppuccin-latte-subtext1) (text . "GNU Emacs")
               (color . catppuccin-latte-base)
               (logo . emacs)))
    (style . shadow)
    (id . gnu-emacs-single)))

(define glyph-emacs-lisp
  `((sections ((background . catppuccin-latte-subtext1) (text . "Emacs")
               (color . catppuccin-latte-base)
               (logo . emacs))
              ((background . catppuccin-mocha-pink) (text . "Lisp")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . emacs-lisp)))

(define glyph-license-mit
  `((sections ((background . catppuccin-latte-subtext1) (text . "license")
               (color . catppuccin-latte-base)
               (logo . scales))
              ((background . catppuccin-mocha-blue) (text . "MIT")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . license-mit)))

(define glyph-license-gpl3+
  `((sections ((background . catppuccin-latte-subtext1) (text . "license")
               (color . catppuccin-latte-base)
               (logo . scales))
              ((background . catppuccin-mocha-blue) (text . "GPL v3+")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . license-gpl3+)))

(define glyph-license-lgpl3+
  `((sections ((background . catppuccin-latte-subtext1) (text . "license")
               (color . catppuccin-latte-base)
               (logo . scales))
              ((background . catppuccin-mocha-blue) (text . "LGPL v3+")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . license-lgpl3+)))

(define glyph-license-agpl3+
  `((sections ((background . catppuccin-latte-subtext1) (text . "license")
               (color . catppuccin-latte-base)
               (logo . scales))
              ((background . catppuccin-mocha-blue) (text . "AGPL v3+")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . license-agpl3+)))

(define glyph-license-fdl13+
  `((sections ((background . catppuccin-latte-subtext1) (text . "license")
               (color . catppuccin-latte-base)
               (logo . scales))
              ((background . catppuccin-mocha-blue) (text . "GFDL v1.3+")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . license-fdl13+)))

(define glyph-shell-fish
  `((sections ((background . catppuccin-latte-subtext1) (text . "Shell")
               (color . catppuccin-latte-base)
               (logo . hashtag))
              ((background . catppuccin-mocha-green) (text . "Fish")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . shell-fish)))

(define glyph-shell-bash
  `((sections ((background . catppuccin-latte-subtext1) (text . "Shell")
               (color . catppuccin-latte-base)
               (logo . hashtag))
              ((background . catppuccin-mocha-green) (text . "Bash")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . shell-bash)))

(define glyph-shell-eshell
  `((sections ((background . catppuccin-latte-subtext1) (text . "Shell")
               (color . catppuccin-latte-base)
               (logo . hashtag))
              ((background . catppuccin-mocha-pink) (text . "EShell")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . shell-eshell)))

(define glyph-gnu-artanis
  `((sections ((background . catppuccin-latte-subtext1) (text . "GNU")
               (color . catppuccin-latte-base)
               (logo . lambda))
              ((background . catppuccin-mocha-maroon) (text . "Artanis")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . gnu-artanis)))

(define glyph-gnu-artanis-122
  `((sections ((background . catppuccin-latte-subtext1) (text . "GNU")
               (color . catppuccin-latte-base)
               (logo . lambda)
               (font-weight . 900))
              ((background . catppuccin-mocha-maroon) (text . "Artanis")
               (color . catppuccin-mocha-base)
               (font-weight . 900))
              ((background . catppuccin-latte-subtext1) (text . "v1.2.2")
               (color . catppuccin-latte-base)
               (font-weight . 900)))
    (style . shadow)
    (id . gnu-artanis-122)))

(define glyph-css-tailwind4
  `((sections ((background . catppuccin-latte-subtext1) (text . "CSS")
               (color . catppuccin-latte-base)
               (logo . paint))
              ((background . catppuccin-mocha-sapphire) (text . "Tailwind v4")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . css-tailwind4)))

(define glyph-scala-213
  `((sections ((background . catppuccin-latte-subtext1) (text . "Scala")
               (color . catppuccin-latte-base)
               (logo . scala))
              ((background . catppuccin-mocha-red) (text . "v2.13")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . scala-213)))

(define glyph-jointhefreeworld-org
  `((sections ((background . catppuccin-latte-subtext1) (text . "jointhefreeworld.org")
               (color . catppuccin-latte-base)
               (logo . gear)))
    (style . shadow)
    (id . jointhefreeworld-org)))


(define glyph-sbt
  `((sections ((background . catppuccin-latte-subtext1) (text . "build")
               (color . catppuccin-latte-base)
               (logo . gear))
              ((background . catppuccin-mocha-red) (text . "sbt")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . sbt)))

(define glyph-rust-185+
  `((sections ((background . catppuccin-latte-subtext1) (text . "Rust")
               (color . catppuccin-latte-base)
               (logo . rust))
              ((background . catppuccin-mocha-peach) (text . "1.85+")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . rust-185+)))

(define glyph-cargo
  `((sections ((background . catppuccin-latte-subtext1) (text . "build")
               (color . catppuccin-latte-base)
               (logo . rust))
              ((background . catppuccin-mocha-peach) (text . "cargo")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . cargo)))

(define glyph-justfile
  `((sections ((background . catppuccin-latte-subtext1) (text . "Justfile")
               (color . catppuccin-latte-base)
               (logo . gear)))
    (style . shadow)
    (id . justfile)))

(define glyph-env
  `((sections ((background . catppuccin-latte-subtext1) (text . ".env")
               (color . catppuccin-latte-base)
               (logo . gear)))
    (style . shadow)
    (id . env)))

(define glyph-java-25
  `((sections ((background . catppuccin-latte-subtext1) (text . "Java")
               (color . catppuccin-latte-base)
               (logo . java))
              ((background . catppuccin-mocha-red) (text . "OpenJDK 25")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . java-25)))

(define glyph-kotlin-2
  `((sections ((background . catppuccin-latte-subtext1) (text . "Kotlin")
               (color . catppuccin-latte-base)
               (logo . code))
              ((background . catppuccin-mocha-mauve) (text . "v2.0+")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . kotlin-2)))

(define glyph-springboot
  `((sections ((background . catppuccin-latte-subtext1) (text . "Spring")
               (color . catppuccin-latte-base)
               (logo . springboot))
              ((background . catppuccin-mocha-green) (text . "Boot")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . spring-boot)))

(define glyph-scala-3
  `((sections ((background . catppuccin-latte-subtext1) (text . "Scala")
               (color . catppuccin-latte-base)
               (logo . scala))
              ((background . catppuccin-mocha-red) (text . "v3.x")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . scala-3)))

(define glyph-build-gradle
  `((sections ((background . catppuccin-latte-subtext1) (text . "build")
               (color . catppuccin-latte-base)
               (logo . gear))
              ((background . catppuccin-mocha-teal) (text . "Gradle")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . build-gradle)))

(define glyph-build-maven
  `((sections ((background . catppuccin-latte-subtext1) (text . "build")
               (color . catppuccin-latte-base)
               (logo . gear))
              ((background . catppuccin-mocha-red) (text . "Maven")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . build-maven)))

(define glyph-lisp-sbcl
  `((sections ((background . catppuccin-latte-subtext1) (text . "Lisp")
               (color . catppuccin-latte-base)
               (logo . lambda))
              ((background . catppuccin-mocha-maroon) (text . "SBCL")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . lisp-sbcl)))

(define glyph-scheme-racket
  `((sections ((background . catppuccin-latte-subtext1) (text . "Scheme")
               (color . catppuccin-latte-base)
               (logo . lambda))
              ((background . catppuccin-mocha-blue) (text . "Racket")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . scheme-racket)))

(define glyph-clojure
  `((sections ((background . catppuccin-latte-subtext1) (text . "Lisp")
               (color . catppuccin-latte-base)
               (logo . lambda))
              ((background . catppuccin-mocha-green) (text . "Clojure")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . clojure)))

(define glyph-emacs-org
  `((sections ((background . catppuccin-latte-subtext1) (text . "Emacs")
               (color . catppuccin-latte-base)
               (logo . emacs))
              ((background . catppuccin-mocha-teal) (text . "Org-mode")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . emacs-org)))

(define glyph-emacs-magit
  `((sections ((background . catppuccin-latte-subtext1) (text . "Emacs")
               (color . catppuccin-latte-base)
               (logo . emacs))
              ((background . catppuccin-mocha-mauve) (text . "Magit")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . emacs-magit)))

(define glyph-dev-docker
  `((sections ((background . catppuccin-latte-subtext1) (text . "Docker")
               (color . catppuccin-latte-base)
               (logo . cube))
              ((background . catppuccin-mocha-blue) (text . "ready")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . dev-docker)))

(define glyph-nix-flake
  `((sections ((background . catppuccin-latte-subtext1) (text . "Nix")
               (color . catppuccin-latte-base)
               (logo . snowflake))
              ((background . catppuccin-mocha-sapphire) (text . "flake")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . nix-flake)))

(define glyph-lang-c
  `((sections ((background . catppuccin-latte-subtext1) (text . "C")
               (color . catppuccin-latte-base)
               (logo . code))
              ((background . catppuccin-mocha-blue) (text . "17")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . lang-c)))

(define glyph-gtk4
  `((sections ((background . catppuccin-latte-subtext1) (text . "GTK")
               (color . catppuccin-latte-base)
               (logo . gear))
              ((background . catppuccin-mocha-blue) (text . "v4")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . gtk4)))

(define glyph-build-meson
  `((sections ((background . catppuccin-latte-subtext1) (text . "build")
               (color . catppuccin-latte-base)
               (logo . gear))
              ((background . catppuccin-mocha-teal) (text . "Meson")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . build-meson)))

(define glyph-lang-python
  `((sections ((background . catppuccin-latte-subtext1) (text . "Python")
               (color . catppuccin-latte-base)
               (logo . python))
              ((background . catppuccin-mocha-blue) (text . "3.13")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . lang-python)))

(define glyph-lang-go
  `((sections ((background . catppuccin-latte-subtext1) (text . "Go")
               (color . catppuccin-latte-base)
               (logo . go))
              ((background . catppuccin-mocha-sky) (text . "1.24")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . lang-go)))

(define glyph-build-cmake
  `((sections ((background . catppuccin-latte-subtext1) (text . "build")
               (color . catppuccin-latte-base)
               (logo . cmake))
              ((background . catppuccin-mocha-blue) (text . "CMake")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . build-cmake)))

(define glyph-pkg-homebrew
  `((sections ((background . catppuccin-latte-subtext1) (text . "pkg")
               (color . catppuccin-latte-base)
               (logo . homebrew))
              ((background . catppuccin-mocha-yellow) (text . "Homebrew")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . pkg-homebrew)))

(define glyph-ci-buildkite
  `((sections ((background . catppuccin-latte-subtext1) (text . "CI")
               (color . catppuccin-latte-base)
               (logo . buildkite))
              ((background . catppuccin-mocha-green) (text . "Buildkite")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . ci-buildkite)))

(define glyph-ci-drone
  `((sections ((background . catppuccin-latte-subtext1) (text . "CI")
               (color . catppuccin-latte-base)
               (logo . drone))
              ((background . catppuccin-mocha-sky) (text . "Drone")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . ci-drone)))

(define glyph-ci-travis
  `((sections ((background . catppuccin-latte-subtext1) (text . "CI")
               (color . catppuccin-latte-base)
               (logo . travisci))
              ((background . catppuccin-mocha-maroon) (text . "Travis CI")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . ci-travis)))

(define glyph-test-jest
  `((sections ((background . catppuccin-latte-subtext1) (text . "test")
               (color . catppuccin-latte-base)
               (logo . jest))
              ((background . catppuccin-mocha-red) (text . "Jest")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . test-jest)))

(define glyph-test-vitest
  `((sections ((background . catppuccin-latte-subtext1) (text . "test")
               (color . catppuccin-latte-base)
               (logo . vitest))
              ((background . catppuccin-mocha-green) (text . "Vitest")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . test-vitest)))

(define glyph-test-pytest
  `((sections ((background . catppuccin-latte-subtext1) (text . "test")
               (color . catppuccin-latte-base)
               (logo . pytest))
              ((background . catppuccin-mocha-sky) (text . "pytest")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . test-pytest)))

(define glyph-lint-eslint
  `((sections ((background . catppuccin-latte-subtext1) (text . "lint")
               (color . catppuccin-latte-base)
               (logo . eslint))
              ((background . catppuccin-mocha-lavender) (text . "ESLint")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . lint-eslint)))

(define glyph-fmt-prettier
  `((sections ((background . catppuccin-latte-subtext1) (text . "format")
               (color . catppuccin-latte-base)
               (logo . prettier))
              ((background . catppuccin-mocha-yellow) (text . "Prettier")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . fmt-prettier)))

(define glyph-db-postgresql
  `((sections ((background . catppuccin-latte-subtext1) (text . "db")
               (color . catppuccin-latte-base)
               (logo . postgresql))
              ((background . catppuccin-mocha-blue) (text . "PostgreSQL")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . db-postgresql)))

(define glyph-db-sqlite
  `((sections ((background . catppuccin-latte-subtext1) (text . "db")
               (color . catppuccin-latte-base)
               (logo . sqlite))
              ((background . catppuccin-mocha-sapphire) (text . "SQLite")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . db-sqlite)))

(define glyph-db-redis
  `((sections ((background . catppuccin-latte-subtext1) (text . "db")
               (color . catppuccin-latte-base)
               (logo . redis))
              ((background . catppuccin-mocha-red) (text . "Redis")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . db-redis)))

(define glyph-deploy-kubernetes
  `((sections ((background . catppuccin-latte-subtext1) (text . "deploy")
               (color . catppuccin-latte-base)
               (logo . kubernetes))
              ((background . catppuccin-mocha-blue) (text . "Kubernetes")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . deploy-kubernetes)))

(define glyph-infra-terraform
  `((sections ((background . catppuccin-latte-subtext1) (text . "infra")
               (color . catppuccin-latte-base)
               (logo . terraform))
              ((background . catppuccin-mocha-mauve) (text . "Terraform")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . infra-terraform)))

(define glyph-web-nginx
  `((sections ((background . catppuccin-latte-subtext1) (text . "server")
               (color . catppuccin-latte-base)
               (logo . nginx))
              ((background . catppuccin-mocha-green) (text . "NGINX")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . web-nginx)))

(define glyph-shell-zsh
  `((sections ((background . catppuccin-latte-subtext1) (text . "Shell")
               (color . catppuccin-latte-base)
               (logo . zsh))
              ((background . catppuccin-mocha-peach) (text . "Zsh")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . shell-zsh)))

(define glyph-docs-markdown
  `((sections ((background . catppuccin-latte-subtext1) (text . "docs")
               (color . catppuccin-latte-base)
               (logo . markdown))
              ((background . catppuccin-mocha-flamingo) (text . "Markdown")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . docs-markdown)))

;; ====== Rust and Cargo ======
;;
;; The toolchain a Rust checkout ticks off: the edition it pins, and the three
;; cargo subcommands that have to pass before a change lands. The edition and
;; `cargo test' keep the Rust peach; clippy joins the lavender lints and rustfmt
;; the yellow formatters, so a row of `lint', `format' and `test' badges reads
;; the same whoever writes it.

(define glyph-rust-edition-2021
  `((sections ((background . catppuccin-latte-subtext1) (text . "Rust")
               (color . catppuccin-latte-base)
               (logo . rust))
              ((background . catppuccin-mocha-peach) (text . "edition 2021")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . rust-edition-2021)))

(define glyph-cargo-test
  `((sections ((background . catppuccin-latte-subtext1) (text . "test")
               (color . catppuccin-latte-base)
               (logo . rust))
              ((background . catppuccin-mocha-peach) (text . "cargo test")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . cargo-test)))

(define glyph-cargo-clippy
  `((sections ((background . catppuccin-latte-subtext1) (text . "lint")
               (color . catppuccin-latte-base)
               (logo . shield-check))
              ((background . catppuccin-mocha-lavender) (text . "clippy")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . cargo-clippy)))

(define glyph-cargo-fmt
  `((sections ((background . catppuccin-latte-subtext1) (text . "format")
               (color . catppuccin-latte-base)
               (logo . rust))
              ((background . catppuccin-mocha-yellow) (text . "rustfmt")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . cargo-fmt)))

(define glyph-rust-tokio
  `((sections ((background . catppuccin-latte-subtext1) (text . "Rust")
               (color . catppuccin-latte-base)
               (logo . bolt))
              ((background . catppuccin-mocha-teal) (text . "tokio")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . rust-tokio)))

(define glyph-rust-gtk4
  `((sections ((background . catppuccin-latte-subtext1) (text . "Rust")
               (color . catppuccin-latte-base)
               (logo . rust))
              ((background . catppuccin-mocha-blue) (text . "GTK4")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . rust-gtk4)))

;; ====== The rest of the toolchain in this tree ======
;;
;; One badge per thing the checkouts beside ggg in this tree tick off: the Vite
;; dashboard, the Meson projects that drive Ninja, the two CI systems, the init
;; the Guix hosts run, the containers, the reverse proxy, the two observability
;; services, the two data formats and the two desktop layers.

(define glyph-lang-typescript
  `((sections ((background . catppuccin-latte-subtext1) (text . "TypeScript")
               (color . catppuccin-latte-base)
               (logo . typescript))
              ((background . catppuccin-mocha-blue) (text . "6.0")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . lang-typescript)))

(define glyph-web-react
  `((sections ((background . catppuccin-latte-subtext1) (text . "web")
               (color . catppuccin-latte-base)
               (logo . react))
              ((background . catppuccin-mocha-sky) (text . "React 19")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . web-react)))

(define glyph-build-vite
  `((sections ((background . catppuccin-latte-subtext1) (text . "build")
               (color . catppuccin-latte-base)
               (logo . vite))
              ((background . catppuccin-mocha-mauve) (text . "Vite 8")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . build-vite)))

(define glyph-build-ninja
  `((sections ((background . catppuccin-latte-subtext1) (text . "build")
               (color . catppuccin-latte-base)
               (logo . gear))
              ((background . catppuccin-mocha-teal) (text . "Ninja")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . build-ninja)))

(define glyph-ci-github-actions
  `((sections ((background . catppuccin-latte-subtext1) (text . "CI")
               (color . catppuccin-latte-base)
               (logo . githubactions))
              ((background . catppuccin-mocha-blue) (text . "Actions")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . ci-github-actions)))

(define glyph-ci-woodpecker
  `((sections ((background . catppuccin-latte-subtext1) (text . "CI")
               (color . catppuccin-latte-base)
               (logo . bolt))
              ((background . catppuccin-mocha-green) (text . "Woodpecker")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . ci-woodpecker)))

(define glyph-deploy-shepherd
  `((sections ((background . catppuccin-latte-subtext1) (text . "deploy")
               (color . catppuccin-latte-base)
               (logo . gear))
              ((background . catppuccin-mocha-maroon) (text . "Shepherd")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . deploy-shepherd)))

(define glyph-dev-podman
  `((sections ((background . catppuccin-latte-subtext1) (text . "Podman")
               (color . catppuccin-latte-base)
               (logo . podman))
              ((background . catppuccin-mocha-mauve) (text . "containers")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . dev-podman)))

(define glyph-web-caddy
  `((sections ((background . catppuccin-latte-subtext1) (text . "server")
               (color . catppuccin-latte-base)
               (logo . caddy))
              ((background . catppuccin-mocha-sky) (text . "Caddy")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . web-caddy)))

(define glyph-obs-prometheus
  `((sections ((background . catppuccin-latte-subtext1) (text . "metrics")
               (color . catppuccin-latte-base)
               (logo . prometheus))
              ((background . catppuccin-mocha-red) (text . "Prometheus")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . obs-prometheus)))

(define glyph-obs-grafana
  `((sections ((background . catppuccin-latte-subtext1) (text . "dashboards")
               (color . catppuccin-latte-base)
               (logo . grafana))
              ((background . catppuccin-mocha-yellow) (text . "Grafana")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . obs-grafana)))

(define glyph-data-json
  `((sections ((background . catppuccin-latte-subtext1) (text . "data")
               (color . catppuccin-latte-base)
               (logo . json))
              ((background . catppuccin-mocha-yellow) (text . "JSON")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . data-json)))

(define glyph-data-yaml
  `((sections ((background . catppuccin-latte-subtext1) (text . "config")
               (color . catppuccin-latte-base)
               (logo . yaml))
              ((background . catppuccin-mocha-teal) (text . "YAML")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . data-yaml)))

(define glyph-dev-wayland
  `((sections ((background . catppuccin-latte-subtext1) (text . "display")
               (color . catppuccin-latte-base)
               (logo . wayland))
              ((background . catppuccin-mocha-mauve) (text . "Wayland")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . dev-wayland)))

(define glyph-test-junit
  `((sections ((background . catppuccin-latte-subtext1) (text . "test")
               (color . catppuccin-latte-base)
               (logo . shield-check))
              ((background . catppuccin-mocha-maroon) (text . "JUnit 5")
               (color . catppuccin-mocha-base)))
    (style . shadow)
    (id . test-junit)))

;; ====== Crystal glass, in the other palettes ======
;;
;; The frosted glass that (style . crystal) draws again, this time with accent
;; sides from the palettes outside Catppuccin -- Doom, Dracula, Dracula Alucard,
;; Solarized, Modus Vivendi and Modus Operandi -- plus the macchiato and frappe
;; flavors, and the last four set in a monospace font (style . crystal-mono), so
;; the two type variants can be compared.
;;
;; The label side stays the latte `subtext1' gray with `base' text (5.5:1) it
;; wears everywhere else, and each accent keeps its theme's own ink, so every
;; second section stays at 4.5:1 or better while the glass warms it.

(define glyph-crystal-gnu-guix
  `((sections ((background . catppuccin-latte-subtext1) (text . "GNU")
               (color . catppuccin-latte-base)
               (logo . gnu))
              ((background . doom-one-yellow) (text . "Guix")
               (color . doom-one-base0)))
    (style . crystal)
    (id . crystal-gnu-guix)))

(define glyph-crystal-scheme-guile
  `((sections ((background . catppuccin-latte-subtext1) (text . "Scheme")
               (color . catppuccin-latte-base)
               (logo . lambda))
              ((background . dracula-orange) (text . "Guile")
               (color . dracula-background)))
    (style . crystal)
    (id . crystal-scheme-guile)))

(define glyph-crystal-lang-python
  `((sections ((background . catppuccin-latte-subtext1) (text . "Python")
               (color . catppuccin-latte-base)
               (logo . python))
              ((background . catppuccin-macchiato-green) (text . "3.13")
               (color . catppuccin-macchiato-base)))
    (style . crystal)
    (id . crystal-lang-python)))

(define glyph-crystal-db-postgresql
  `((sections ((background . catppuccin-latte-subtext1) (text . "db")
               (color . catppuccin-latte-base)
               (logo . postgresql))
              ((background . catppuccin-frappe-blue) (text . "PostgreSQL")
               (color . catppuccin-frappe-base)))
    (style . crystal)
    (id . crystal-db-postgresql)))

(define glyph-crystal-mono-maak
  `((sections ((background . catppuccin-latte-subtext1) (text . "maak")
               (color . catppuccin-latte-base)
               (logo . maak))
              ((background . modus-vivendi-magenta) (text . "tasks")
               (color . modus-vivendi-bg-main)))
    (style . crystal-mono)
    (id . crystal-mono-maak)))

(define glyph-crystal-mono-lang-go
  `((sections ((background . catppuccin-latte-subtext1) (text . "Go")
               (color . catppuccin-latte-base)
               (logo . go))
              ((background . modus-operandi-red) (text . "1.24")
               (color . modus-operandi-bg-main)))
    (style . crystal-mono)
    (id . crystal-mono-lang-go)))

(define glyph-crystal-mono-test-pytest
  `((sections ((background . catppuccin-latte-subtext1) (text . "test")
               (color . catppuccin-latte-base)
               (logo . pytest))
              ((background . solarized-dark-base03) (text . "pytest")
               (color . solarized-dark-cyan)))
    (style . crystal-mono)
    (id . crystal-mono-test-pytest)))

(define glyph-crystal-mono-license-mit
  `((sections ((background . catppuccin-latte-subtext1) (text . "license")
               (color . catppuccin-latte-base)
               (logo . scales))
              ((background . dracula-alucard-purple) (text . "MIT")
               (color . dracula-alucard-background)))
    (style . crystal-mono)
    (id . crystal-mono-license-mit)))

;; ====== The two sets ======
;;
;; Every badge above is declared once and rendered twice.  The crystal copy --
;; the frosted glass in the system sans font, with the colors the badge asks
;; for -- takes the plain id, so `lang-python' is the badge a project links to.
;; The finish the set shipped with before the glass, the subtle shadow, is kept
;; beside it under a `showcase-' id, so the old look is still browsable in the
;; gallery and a row of both sets shows what changed.

(define (crystal-badge glyph)
  "GLYPH behind the frosted glass, in the system sans font."
  (cons (cons 'style 'crystal)
        (filter (lambda (entry) (not (eq? (car entry) 'style))) glyph)))

(define (showcase-badge glyph)
  "GLYPH under a `showcase-' id, in the shadow finish it shipped with."
  (cons (cons 'id (string->symbol
                   (string-append "showcase-" (symbol->string (assq-ref glyph 'id)))))
        (filter (lambda (entry) (not (eq? (car entry) 'id))) glyph)))

(define the-badges
  (list glyph-pipeline-succeeded
        glyph-gnu-guix
        glyph-scheme-guile
        glyph-haskell-ghc910
        glyph-gnu-make
        glyph-gnu-emacs
        glyph-gnu-emacs-single
        glyph-emacs-lisp
        glyph-i18n-gnu-gettext
        glyph-license-gpl3+
        glyph-license-lgpl3+
        glyph-license-agpl3+
        glyph-license-fdl13+
        glyph-license-mit
        glyph-shell-fish
        glyph-shell-bash
        glyph-shell-eshell
        glyph-gnu-artanis
        glyph-gnu-artanis-122
        glyph-css-tailwind4
        glyph-jointhefreeworld-org
        glyph-scala-213
        glyph-justfile
        glyph-sbt
        glyph-rust-185+
        glyph-cargo
        glyph-maak
        glyph-byggsteg
        glyph-byggsteg-github
        glyph-github-mirror
        glyph-lucidplan
        glyph-bewaking
        glyph-hygguile
        glyph-veritas
        glyph-symbanta
        glyph-java-25
        glyph-kotlin-2
        glyph-springboot
        glyph-scala-3
        glyph-build-gradle
        glyph-build-maven
        glyph-lisp-sbcl
        glyph-scheme-racket
        glyph-clojure
        glyph-emacs-org
        glyph-emacs-magit
        glyph-dev-docker
        glyph-nix-flake
        glyph-build-meson
        glyph-gtk4
        glyph-lang-c
        glyph-env
        ;; Languages, builds, packages and CI
        glyph-lang-python
        glyph-lang-go
        glyph-build-cmake
        glyph-pkg-homebrew
        glyph-ci-buildkite
        glyph-ci-drone
        glyph-ci-travis
        ;; Tests, linting and formatting
        glyph-test-jest
        glyph-test-vitest
        glyph-test-pytest
        glyph-lint-eslint
        glyph-fmt-prettier
        ;; Data, deployment, servers and docs
        glyph-db-postgresql
        glyph-db-sqlite
        glyph-db-redis
        glyph-deploy-kubernetes
        glyph-infra-terraform
        glyph-web-nginx
        glyph-shell-zsh
        glyph-docs-markdown
        ;; Rust and Cargo
        glyph-rust-edition-2021
        glyph-cargo-test
        glyph-cargo-clippy
        glyph-cargo-fmt
        glyph-rust-tokio
        glyph-rust-gtk4
        ;; The rest of the toolchain in this tree
        glyph-lang-typescript
        glyph-web-react
        glyph-build-vite
        glyph-build-ninja
        glyph-ci-github-actions
        glyph-ci-woodpecker
        glyph-deploy-shepherd
        glyph-dev-podman
        glyph-web-caddy
        glyph-obs-prometheus
        glyph-obs-grafana
        glyph-data-json
        glyph-data-yaml
        glyph-dev-wayland
        glyph-test-junit))

(define ggg-glyphs
  (append
   ;; The set a project links to, in crystal glass.
   (map crystal-badge the-badges)
   ;; The same badges as the showcase keeps them, in the shadow finish.
   (map showcase-badge the-badges)
   ;; The glass in the other palettes, and in a monospace font.
   (list glyph-crystal-gnu-guix
         glyph-crystal-scheme-guile
         glyph-crystal-lang-python
         glyph-crystal-db-postgresql
         glyph-crystal-mono-maak
         glyph-crystal-mono-lang-go
         glyph-crystal-mono-test-pytest
         glyph-crystal-mono-license-mit)))

