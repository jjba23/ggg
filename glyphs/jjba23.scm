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

;; Commentary:
;;
;; The badges below are colored with the Catppuccin palette (the mocha flavor),
;; whose colors ggg knows by name: every color of every supported theme is
;; available as "<theme>-<color>". Since Catppuccin accents are light, the text
;; on them is that theme's dark background shade -- `catppuccin-mocha-base' for
;; mocha, `doom-one-bg' for Doom, `dracula-background' for Dracula -- and the
;; neutral first section (the one holding the logo) is `catppuccin-mocha-surface2'
;; with `catppuccin-mocha-text'.
;;
;; The accents lean warm: the licenses and the docs badge wear warm neutrals
;; (rosewater, flamingo) instead of the old cold gray, and two project badges
;; borrow an orange from Dracula and a yellow from Doom. Badges that stand for
;; a brand keep that brand's hue.
;;
;; `ggg --list-colors` prints every theme and color; see the README for the
;; other palettes.

(define-module (ggg config)
  #:declarative? #t)

(define glyph-pipeline-succeeded
  `((sections ((background . catppuccin-mocha-surface2) (text . "pipeline")
               (color . catppuccin-mocha-text))
              ((background . catppuccin-mocha-green) (text . "succeeded")
               (color . catppuccin-mocha-base)))
    (id . pipeline-succeeded)))

(define glyph-gnu-guix
  `((sections ((background . catppuccin-mocha-surface2) (text . "GNU")
               (color . catppuccin-mocha-text)
               (logo . gnu))
              ((background . catppuccin-mocha-yellow) (text . "Guix")
               (color . catppuccin-mocha-base)))
    (id . gnu-guix)))

(define glyph-scheme-guile
  `((sections ((background . catppuccin-mocha-surface2) (text . "Scheme")
               (color . catppuccin-mocha-text)
               (logo . lambda))
              ((background . catppuccin-mocha-peach) (text . "Guile")
               (color . catppuccin-mocha-base)))
    (id . scheme-guile)))

(define glyph-haskell-ghc910
  `((sections ((background . catppuccin-mocha-surface2)
               (text . "Haskell")
               (color . catppuccin-mocha-text)
               (logo . lambda))
              ((background . catppuccin-mocha-mauve) (text . "GHC 9.10")
               (color . catppuccin-mocha-base)))
    (id . haskell-ghc910)))

(define glyph-gnu-make
  `((sections ((background . catppuccin-mocha-surface2) (text . "GNU")
               (color . catppuccin-mocha-text)
               (logo . gnu))
              ((background . catppuccin-mocha-red) (text . "Make")
               (color . catppuccin-mocha-base)))
    (id . gnu-make)))

(define glyph-maak
  `((sections ((background . catppuccin-mocha-surface2) (text . "maak")
               (color . catppuccin-mocha-text)
               (logo . maak))
              ((background . catppuccin-mocha-peach) (text . "tasks")
               (color . catppuccin-mocha-base)))
    (id . maak)))

(define glyph-byggsteg
  `((sections ((background . catppuccin-mocha-surface2) (text . "byggsteg")
               (color . catppuccin-mocha-text)
               (logo . byggsteg))
              ((background . catppuccin-mocha-green) (text . "CI/CD")
               (color . catppuccin-mocha-base)))
    (id . byggsteg)))

(define glyph-lucidplan
  `((sections ((background . catppuccin-mocha-surface2) (text . "LucidPlan")
               (color . catppuccin-mocha-text)
               (logo . lucidplan))
              ((background . dracula-orange) (text . "planning")
               (color . dracula-background)))
    (id . lucidplan)))

(define glyph-bewaking
  `((sections ((background . catppuccin-mocha-surface2) (text . "bewaking")
               (color . catppuccin-mocha-text)
               (logo . bewaking))
              ((background . catppuccin-mocha-maroon) (text . "security")
               (color . catppuccin-mocha-base)))
    (id . bewaking)))

(define glyph-hygguile
  `((sections ((background . catppuccin-mocha-surface2) (text . "Hygguile")
               (color . catppuccin-mocha-text)
               (logo . hygguile))
              ((background . catppuccin-mocha-rosewater) (text . "UI")
               (color . catppuccin-mocha-base)))
    (id . hygguile)))

(define glyph-veritas
  `((sections ((background . catppuccin-mocha-surface2) (text . "Veritas")
               (color . catppuccin-mocha-text)
               (logo . veritas))
              ((background . doom-one-yellow) (text . "testing")
               (color . doom-one-bg)))
    (id . veritas)))

(define glyph-symbanta
  `((sections ((background . catppuccin-mocha-surface2) (text . "Symbanta")
               (color . catppuccin-mocha-text)
               (logo . symbanta))
              ((background . catppuccin-mocha-pink) (text . "analytics")
               (color . catppuccin-mocha-base)))
    (id . symbanta)))

(define glyph-i18n-gnu-gettext
  `((sections ((background . catppuccin-mocha-surface2) (text . "i18n")
               (color . catppuccin-mocha-text)
               (logo . language))
              ((background . catppuccin-mocha-red) (text . "GNU gettext")
               (color . catppuccin-mocha-base)))
    (id . i18n-gnu-gettext)))

(define glyph-gnu-emacs
  `((sections ((background . catppuccin-mocha-surface2) (text . "GNU")
               (color . catppuccin-mocha-text)
               (logo . emacs))
              ((background . catppuccin-mocha-pink) (text . "Emacs")
               (color . catppuccin-mocha-base)))
    (id . gnu-emacs)))

(define glyph-gnu-emacs-single
  `((sections ((background . catppuccin-mocha-surface2) (text . "GNU Emacs")
               (color . catppuccin-mocha-text)
               (logo . emacs)))
    (id . gnu-emacs-single)))

(define glyph-emacs-lisp
  `((sections ((background . catppuccin-mocha-surface2) (text . "Emacs")
               (color . catppuccin-mocha-text)
               (logo . emacs))
              ((background . catppuccin-mocha-pink) (text . "Lisp")
               (color . catppuccin-mocha-base)))
    (id . emacs-lisp)))

(define glyph-license-gpl3+
  `((sections ((background . catppuccin-mocha-surface2) (text . "license")
               (color . catppuccin-mocha-text)
               (logo . scales))
              ((background . catppuccin-mocha-rosewater) (text . "GPL v3+")
               (color . catppuccin-mocha-base)))
    (id . license-gpl3+)))

(define glyph-license-lgpl3+
  `((sections ((background . catppuccin-mocha-surface2) (text . "license")
               (color . catppuccin-mocha-text)
               (logo . scales))
              ((background . catppuccin-mocha-rosewater) (text . "LGPL v3+")
               (color . catppuccin-mocha-base)))
    (id . license-lgpl3+)))

(define glyph-license-agpl3+
  `((sections ((background . catppuccin-mocha-surface2) (text . "license")
               (color . catppuccin-mocha-text)
               (logo . scales))
              ((background . catppuccin-mocha-rosewater) (text . "AGPL v3+")
               (color . catppuccin-mocha-base)))
    (id . license-agpl3+)))

(define glyph-license-fdl13+
  `((sections ((background . catppuccin-mocha-surface2) (text . "license")
               (color . catppuccin-mocha-text)
               (logo . scales))
              ((background . catppuccin-mocha-rosewater) (text . "GFDL v1.3+")
               (color . catppuccin-mocha-base)))
    (id . license-fdl13+)))

(define glyph-shell-fish
  `((sections ((background . catppuccin-mocha-surface2) (text . "Shell")
               (color . catppuccin-mocha-text)
               (logo . hashtag))
              ((background . catppuccin-mocha-green) (text . "Fish")
               (color . catppuccin-mocha-base)))
    (id . shell-fish)))

(define glyph-shell-bash
  `((sections ((background . catppuccin-mocha-surface2) (text . "Shell")
               (color . catppuccin-mocha-text)
               (logo . hashtag))
              ((background . catppuccin-mocha-green) (text . "Bash")
               (color . catppuccin-mocha-base)))
    (id . shell-bash)))

(define glyph-shell-eshell
  `((sections ((background . catppuccin-mocha-surface2) (text . "Shell")
               (color . catppuccin-mocha-text)
               (logo . hashtag))
              ((background . catppuccin-mocha-pink) (text . "EShell")
               (color . catppuccin-mocha-base)))
    (id . shell-eshell)))

(define glyph-gnu-artanis
  `((sections ((background . catppuccin-mocha-surface2) (text . "GNU")
               (color . catppuccin-mocha-text)
               (logo . lambda))
              ((background . catppuccin-mocha-maroon) (text . "Artanis")
               (color . catppuccin-mocha-base)))
    (id . gnu-artanis)))

(define glyph-gnu-artanis-122
  `((sections ((background . catppuccin-mocha-surface2) (text . "GNU")
               (color . catppuccin-mocha-text)
               (logo . lambda)
               (font-weight . 900))
              ((background . catppuccin-mocha-maroon) (text . "Artanis")
               (color . catppuccin-mocha-base)
               (font-weight . 900))
              ((background . catppuccin-mocha-surface2) (text . "v1.2.2")
               (color . catppuccin-mocha-text)
               (font-weight . 900)))
    (id . gnu-artanis-122)))

(define glyph-css-tailwind4
  `((sections ((background . catppuccin-mocha-surface2) (text . "CSS")
               (color . catppuccin-mocha-text)
               (logo . paint))
              ((background . catppuccin-mocha-sapphire) (text . "Tailwind v4")
               (color . catppuccin-mocha-base)))
    (id . css-tailwind4)))

(define glyph-scala-213
  `((sections ((background . catppuccin-mocha-surface2) (text . "Scala")
               (color . catppuccin-mocha-text)
               (logo . scala))
              ((background . catppuccin-mocha-red) (text . "v2.13")
               (color . catppuccin-mocha-base)))
    (id . scala-213)))

(define glyph-jointhefreeworld-org
  `((sections ((background . catppuccin-mocha-surface2) (text . "jointhefreeworld.org")
               (color . catppuccin-mocha-text)
               (logo . gear)))
    (id . jointhefreeworld-org)))


(define glyph-sbt
  `((sections ((background . catppuccin-mocha-surface2) (text . "build")
               (color . catppuccin-mocha-text)
               (logo . gear))
              ((background . catppuccin-mocha-red) (text . "sbt")
               (color . catppuccin-mocha-base)))
    (id . sbt)))

(define glyph-rust-185+
  `((sections ((background . catppuccin-mocha-surface2) (text . "Rust")
               (color . catppuccin-mocha-text)
               (logo . rust))
              ((background . catppuccin-mocha-peach) (text . "1.85+")
               (color . catppuccin-mocha-base)))
    (id . rust-185+)))

(define glyph-cargo
  `((sections ((background . catppuccin-mocha-surface2) (text . "build")
               (color . catppuccin-mocha-text)
               (logo . rust))
              ((background . catppuccin-mocha-peach) (text . "cargo")
               (color . catppuccin-mocha-base)))
    (id . cargo)))

(define glyph-justfile
  `((sections ((background . catppuccin-mocha-surface2) (text . "Justfile")
               (color . catppuccin-mocha-text)
               (logo . gear)))
    (id . justfile)))

(define glyph-env
  `((sections ((background . catppuccin-mocha-surface2) (text . ".env")
               (color . catppuccin-mocha-text)
               (logo . gear)))
    (id . env)))

(define glyph-java-25
  `((sections ((background . catppuccin-mocha-surface2) (text . "Java")
               (color . catppuccin-mocha-text)
               (logo . java))
              ((background . catppuccin-mocha-red) (text . "OpenJDK 25")
               (color . catppuccin-mocha-base)))
    (id . java-25)))

(define glyph-kotlin-2
  `((sections ((background . catppuccin-mocha-surface2) (text . "Kotlin")
               (color . catppuccin-mocha-text)
               (logo . code))
              ((background . catppuccin-mocha-mauve) (text . "v2.0+")
               (color . catppuccin-mocha-base)))
    (id . kotlin-2)))

(define glyph-scala-3
  `((sections ((background . catppuccin-mocha-surface2) (text . "Scala")
               (color . catppuccin-mocha-text)
               (logo . scala))
              ((background . catppuccin-mocha-maroon) (text . "v3.x")
               (color . catppuccin-mocha-base)))
    (id . scala-3)))

(define glyph-build-gradle
  `((sections ((background . catppuccin-mocha-surface2) (text . "build")
               (color . catppuccin-mocha-text)
               (logo . gear))
              ((background . catppuccin-mocha-teal) (text . "Gradle")
               (color . catppuccin-mocha-base)))
    (id . build-gradle)))

(define glyph-build-maven
  `((sections ((background . catppuccin-mocha-surface2) (text . "build")
               (color . catppuccin-mocha-text)
               (logo . gear))
              ((background . catppuccin-mocha-red) (text . "Maven")
               (color . catppuccin-mocha-base)))
    (id . build-maven)))

(define glyph-lisp-sbcl
  `((sections ((background . catppuccin-mocha-surface2) (text . "Lisp")
               (color . catppuccin-mocha-text)
               (logo . lambda))
              ((background . catppuccin-mocha-maroon) (text . "SBCL")
               (color . catppuccin-mocha-base)))
    (id . lisp-sbcl)))

(define glyph-scheme-racket
  `((sections ((background . catppuccin-mocha-surface2) (text . "Scheme")
               (color . catppuccin-mocha-text)
               (logo . lambda))
              ((background . catppuccin-mocha-blue) (text . "Racket")
               (color . catppuccin-mocha-base)))
    (id . scheme-racket)))

(define glyph-clojure
  `((sections ((background . catppuccin-mocha-surface2) (text . "Lisp")
               (color . catppuccin-mocha-text)
               (logo . lambda))
              ((background . catppuccin-mocha-green) (text . "Clojure")
               (color . catppuccin-mocha-base)))
    (id . clojure)))

(define glyph-emacs-org
  `((sections ((background . catppuccin-mocha-surface2) (text . "Emacs")
               (color . catppuccin-mocha-text)
               (logo . emacs))
              ((background . catppuccin-mocha-teal) (text . "Org-mode")
               (color . catppuccin-mocha-base)))
    (id . emacs-org)))

(define glyph-emacs-magit
  `((sections ((background . catppuccin-mocha-surface2) (text . "Emacs")
               (color . catppuccin-mocha-text)
               (logo . emacs))
              ((background . catppuccin-mocha-red) (text . "Magit")
               (color . catppuccin-mocha-base)))
    (id . emacs-magit)))

(define glyph-dev-docker
  `((sections ((background . catppuccin-mocha-surface2) (text . "Docker")
               (color . catppuccin-mocha-text)
               (logo . cube))
              ((background . catppuccin-mocha-blue) (text . "ready")
               (color . catppuccin-mocha-base)))
    (id . dev-docker)))

(define glyph-nix-flake
  `((sections ((background . catppuccin-mocha-surface2) (text . "Nix")
               (color . catppuccin-mocha-text)
               (logo . snowflake))
              ((background . catppuccin-mocha-sapphire) (text . "flake")
               (color . catppuccin-mocha-base)))
    (id . nix-flake)))

(define glyph-lang-c
  `((sections ((background . catppuccin-mocha-surface2) (text . "C")
               (color . catppuccin-mocha-text)
               (logo . code))
              ((background . catppuccin-mocha-blue) (text . "17")
               (color . catppuccin-mocha-base)))
    (id . lang-c)))

(define glyph-gtk4
  `((sections ((background . catppuccin-mocha-surface2) (text . "GTK")
               (color . catppuccin-mocha-text)
               (logo . gear))
              ((background . catppuccin-mocha-blue) (text . "v4")
               (color . catppuccin-mocha-base)))
    (id . gtk4)))

(define glyph-build-meson
  `((sections ((background . catppuccin-mocha-surface2) (text . "build")
               (color . catppuccin-mocha-text)
               (logo . gear))
              ((background . catppuccin-mocha-teal) (text . "Meson")
               (color . catppuccin-mocha-base)))
    (id . build-meson)))

(define glyph-lang-python
  `((sections ((background . catppuccin-mocha-surface2) (text . "Python")
               (color . catppuccin-mocha-text)
               (logo . python))
              ((background . catppuccin-mocha-blue) (text . "3.13")
               (color . catppuccin-mocha-base)))
    (id . lang-python)))

(define glyph-lang-go
  `((sections ((background . catppuccin-mocha-surface2) (text . "Go")
               (color . catppuccin-mocha-text)
               (logo . go))
              ((background . catppuccin-mocha-sky) (text . "1.24")
               (color . catppuccin-mocha-base)))
    (id . lang-go)))

(define glyph-build-cmake
  `((sections ((background . catppuccin-mocha-surface2) (text . "build")
               (color . catppuccin-mocha-text)
               (logo . cmake))
              ((background . catppuccin-mocha-blue) (text . "CMake")
               (color . catppuccin-mocha-base)))
    (id . build-cmake)))

(define glyph-pkg-homebrew
  `((sections ((background . catppuccin-mocha-surface2) (text . "pkg")
               (color . catppuccin-mocha-text)
               (logo . homebrew))
              ((background . catppuccin-mocha-yellow) (text . "Homebrew")
               (color . catppuccin-mocha-base)))
    (id . pkg-homebrew)))

(define glyph-ci-buildkite
  `((sections ((background . catppuccin-mocha-surface2) (text . "CI")
               (color . catppuccin-mocha-text)
               (logo . buildkite))
              ((background . catppuccin-mocha-green) (text . "Buildkite")
               (color . catppuccin-mocha-base)))
    (id . ci-buildkite)))

(define glyph-ci-drone
  `((sections ((background . catppuccin-mocha-surface2) (text . "CI")
               (color . catppuccin-mocha-text)
               (logo . drone))
              ((background . catppuccin-mocha-sky) (text . "Drone")
               (color . catppuccin-mocha-base)))
    (id . ci-drone)))

(define glyph-ci-travis
  `((sections ((background . catppuccin-mocha-surface2) (text . "CI")
               (color . catppuccin-mocha-text)
               (logo . travisci))
              ((background . catppuccin-mocha-maroon) (text . "Travis CI")
               (color . catppuccin-mocha-base)))
    (id . ci-travis)))

(define glyph-test-jest
  `((sections ((background . catppuccin-mocha-surface2) (text . "test")
               (color . catppuccin-mocha-text)
               (logo . jest))
              ((background . catppuccin-mocha-red) (text . "Jest")
               (color . catppuccin-mocha-base)))
    (id . test-jest)))

(define glyph-test-vitest
  `((sections ((background . catppuccin-mocha-surface2) (text . "test")
               (color . catppuccin-mocha-text)
               (logo . vitest))
              ((background . catppuccin-mocha-green) (text . "Vitest")
               (color . catppuccin-mocha-base)))
    (id . test-vitest)))

(define glyph-test-pytest
  `((sections ((background . catppuccin-mocha-surface2) (text . "test")
               (color . catppuccin-mocha-text)
               (logo . pytest))
              ((background . catppuccin-mocha-sky) (text . "pytest")
               (color . catppuccin-mocha-base)))
    (id . test-pytest)))

(define glyph-lint-eslint
  `((sections ((background . catppuccin-mocha-surface2) (text . "lint")
               (color . catppuccin-mocha-text)
               (logo . eslint))
              ((background . catppuccin-mocha-lavender) (text . "ESLint")
               (color . catppuccin-mocha-base)))
    (id . lint-eslint)))

(define glyph-fmt-prettier
  `((sections ((background . catppuccin-mocha-surface2) (text . "format")
               (color . catppuccin-mocha-text)
               (logo . prettier))
              ((background . catppuccin-mocha-yellow) (text . "Prettier")
               (color . catppuccin-mocha-base)))
    (id . fmt-prettier)))

(define glyph-db-postgresql
  `((sections ((background . catppuccin-mocha-surface2) (text . "db")
               (color . catppuccin-mocha-text)
               (logo . postgresql))
              ((background . catppuccin-mocha-blue) (text . "PostgreSQL")
               (color . catppuccin-mocha-base)))
    (id . db-postgresql)))

(define glyph-db-sqlite
  `((sections ((background . catppuccin-mocha-surface2) (text . "db")
               (color . catppuccin-mocha-text)
               (logo . sqlite))
              ((background . catppuccin-mocha-sapphire) (text . "SQLite")
               (color . catppuccin-mocha-base)))
    (id . db-sqlite)))

(define glyph-db-redis
  `((sections ((background . catppuccin-mocha-surface2) (text . "db")
               (color . catppuccin-mocha-text)
               (logo . redis))
              ((background . catppuccin-mocha-red) (text . "Redis")
               (color . catppuccin-mocha-base)))
    (id . db-redis)))

(define glyph-deploy-kubernetes
  `((sections ((background . catppuccin-mocha-surface2) (text . "deploy")
               (color . catppuccin-mocha-text)
               (logo . kubernetes))
              ((background . catppuccin-mocha-blue) (text . "Kubernetes")
               (color . catppuccin-mocha-base)))
    (id . deploy-kubernetes)))

(define glyph-infra-terraform
  `((sections ((background . catppuccin-mocha-surface2) (text . "infra")
               (color . catppuccin-mocha-text)
               (logo . terraform))
              ((background . catppuccin-mocha-mauve) (text . "Terraform")
               (color . catppuccin-mocha-base)))
    (id . infra-terraform)))

(define glyph-web-nginx
  `((sections ((background . catppuccin-mocha-surface2) (text . "server")
               (color . catppuccin-mocha-text)
               (logo . nginx))
              ((background . catppuccin-mocha-green) (text . "NGINX")
               (color . catppuccin-mocha-base)))
    (id . web-nginx)))

(define glyph-shell-zsh
  `((sections ((background . catppuccin-mocha-surface2) (text . "Shell")
               (color . catppuccin-mocha-text)
               (logo . zsh))
              ((background . catppuccin-mocha-peach) (text . "Zsh")
               (color . catppuccin-mocha-base)))
    (id . shell-zsh)))

(define glyph-docs-markdown
  `((sections ((background . catppuccin-mocha-surface2) (text . "docs")
               (color . catppuccin-mocha-text)
               (logo . markdown))
              ((background . catppuccin-mocha-flamingo) (text . "Markdown")
               (color . catppuccin-mocha-base)))
    (id . docs-markdown)))

(define ggg-glyphs
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
        glyph-lucidplan
        glyph-bewaking
        glyph-hygguile
        glyph-veritas
        glyph-symbanta
        glyph-java-25
        glyph-kotlin-2
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
        glyph-docs-markdown))
