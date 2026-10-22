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
;; The badges below are colored with the Catppuccin latte palette (the light
;; flavor), whose colors ggg knows by name: every color of every supported theme
;; is available as "<theme>-<color>". Contrast decides the ink of every section.
;; The neutral first section (the one holding the logo) is the darker
;; `catppuccin-latte-subtext1' gray with `catppuccin-latte-base' text (5.5:1),
;; so the white logos stand out. Of the latte accents, red and mauve keep the
;; light `catppuccin-latte-base' text and blue uses plain white; every other
;; accent is a mid-tone where latte's own text shade only reaches 2.7-3.5:1, so
;; it takes the near-black `catppuccin-mocha-crust' instead, which keeps every
;; pair at 4.7:1 or better.
;;
;; The accents lean warm: the licenses and the docs badge wear warm neutrals
;; (rosewater, flamingo) instead of a cold gray, and two project badges use a
;; peach for planning and a yellow for testing. Badges that stand for a brand
;; keep that brand's hue.
;;
;; `ggg --list-colors` prints every theme and color; see the README for the
;; other palettes.

(define-module (ggg config)
  #:declarative? #t)

(define glyph-pipeline-succeeded
  `((sections ((background . catppuccin-latte-subtext1) (text . "pipeline")
               (color . catppuccin-latte-base))
              ((background . catppuccin-latte-green) (text . "succeeded")
               (color . catppuccin-mocha-crust)))
    (id . pipeline-succeeded)))

(define glyph-gnu-guix
  `((sections ((background . catppuccin-latte-subtext1) (text . "GNU")
               (color . catppuccin-latte-base)
               (logo . gnu))
              ((background . catppuccin-latte-yellow) (text . "Guix")
               (color . catppuccin-mocha-crust)))
    (id . gnu-guix)))

(define glyph-scheme-guile
  `((sections ((background . catppuccin-latte-subtext1) (text . "Scheme")
               (color . catppuccin-latte-base)
               (logo . lambda))
              ((background . catppuccin-latte-peach) (text . "Guile")
               (color . catppuccin-mocha-crust)))
    (id . scheme-guile)))

(define glyph-haskell-ghc910
  `((sections ((background . catppuccin-latte-subtext1)
               (text . "Haskell")
               (color . catppuccin-latte-base)
               (logo . lambda))
              ((background . catppuccin-latte-mauve) (text . "GHC 9.10")
               (color . catppuccin-latte-base)))
    (id . haskell-ghc910)))

(define glyph-gnu-make
  `((sections ((background . catppuccin-latte-subtext1) (text . "GNU")
               (color . catppuccin-latte-base)
               (logo . gnu))
              ((background . catppuccin-latte-red) (text . "Make")
               (color . catppuccin-latte-base)))
    (id . gnu-make)))

(define glyph-maak
  `((sections ((background . catppuccin-latte-subtext1) (text . "maak")
               (color . catppuccin-latte-base)
               (logo . maak))
              ((background . catppuccin-latte-peach) (text . "tasks")
               (color . catppuccin-mocha-crust)))
    (id . maak)))

(define glyph-byggsteg
  `((sections ((background . catppuccin-latte-subtext1) (text . "byggsteg")
               (color . catppuccin-latte-base)
               (logo . byggsteg))
              ((background . catppuccin-latte-green) (text . "CI/CD")
               (color . catppuccin-mocha-crust)))
    (id . byggsteg)))

(define glyph-lucidplan
  `((sections ((background . catppuccin-latte-subtext1) (text . "LucidPlan")
               (color . catppuccin-latte-base)
               (logo . lucidplan))
              ((background . catppuccin-latte-peach) (text . "planning")
               (color . catppuccin-mocha-crust)))
    (id . lucidplan)))

(define glyph-bewaking
  `((sections ((background . catppuccin-latte-subtext1) (text . "bewaking")
               (color . catppuccin-latte-base)
               (logo . bewaking))
              ((background . catppuccin-latte-maroon) (text . "security")
               (color . catppuccin-mocha-crust)))
    (id . bewaking)))

(define glyph-hygguile
  `((sections ((background . catppuccin-latte-subtext1) (text . "Hygguile")
               (color . catppuccin-latte-base)
               (logo . hygguile))
              ((background . catppuccin-latte-rosewater) (text . "UI")
               (color . catppuccin-mocha-crust)))
    (id . hygguile)))

(define glyph-veritas
  `((sections ((background . catppuccin-latte-subtext1) (text . "Veritas")
               (color . catppuccin-latte-base)
               (logo . veritas))
              ((background . catppuccin-latte-yellow) (text . "testing")
               (color . catppuccin-mocha-crust)))
    (id . veritas)))

(define glyph-symbanta
  `((sections ((background . catppuccin-latte-subtext1) (text . "Symbanta")
               (color . catppuccin-latte-base)
               (logo . symbanta))
              ((background . catppuccin-latte-pink) (text . "analytics")
               (color . catppuccin-mocha-crust)))
    (id . symbanta)))

(define glyph-i18n-gnu-gettext
  `((sections ((background . catppuccin-latte-subtext1) (text . "i18n")
               (color . catppuccin-latte-base)
               (logo . language))
              ((background . catppuccin-latte-red) (text . "GNU gettext")
               (color . catppuccin-latte-base)))
    (id . i18n-gnu-gettext)))

(define glyph-gnu-emacs
  `((sections ((background . catppuccin-latte-subtext1) (text . "GNU")
               (color . catppuccin-latte-base)
               (logo . emacs))
              ((background . catppuccin-latte-pink) (text . "Emacs")
               (color . catppuccin-mocha-crust)))
    (id . gnu-emacs)))

(define glyph-gnu-emacs-single
  `((sections ((background . catppuccin-latte-subtext1) (text . "GNU Emacs")
               (color . catppuccin-latte-base)
               (logo . emacs)))
    (id . gnu-emacs-single)))

(define glyph-emacs-lisp
  `((sections ((background . catppuccin-latte-subtext1) (text . "Emacs")
               (color . catppuccin-latte-base)
               (logo . emacs))
              ((background . catppuccin-latte-pink) (text . "Lisp")
               (color . catppuccin-mocha-crust)))
    (id . emacs-lisp)))

(define glyph-license-gpl3+
  `((sections ((background . catppuccin-latte-subtext1) (text . "license")
               (color . catppuccin-latte-base)
               (logo . scales))
              ((background . catppuccin-latte-rosewater) (text . "GPL v3+")
               (color . catppuccin-mocha-crust)))
    (id . license-gpl3+)))

(define glyph-license-lgpl3+
  `((sections ((background . catppuccin-latte-subtext1) (text . "license")
               (color . catppuccin-latte-base)
               (logo . scales))
              ((background . catppuccin-latte-rosewater) (text . "LGPL v3+")
               (color . catppuccin-mocha-crust)))
    (id . license-lgpl3+)))

(define glyph-license-agpl3+
  `((sections ((background . catppuccin-latte-subtext1) (text . "license")
               (color . catppuccin-latte-base)
               (logo . scales))
              ((background . catppuccin-latte-rosewater) (text . "AGPL v3+")
               (color . catppuccin-mocha-crust)))
    (id . license-agpl3+)))

(define glyph-license-fdl13+
  `((sections ((background . catppuccin-latte-subtext1) (text . "license")
               (color . catppuccin-latte-base)
               (logo . scales))
              ((background . catppuccin-latte-rosewater) (text . "GFDL v1.3+")
               (color . catppuccin-mocha-crust)))
    (id . license-fdl13+)))

(define glyph-shell-fish
  `((sections ((background . catppuccin-latte-subtext1) (text . "Shell")
               (color . catppuccin-latte-base)
               (logo . hashtag))
              ((background . catppuccin-latte-green) (text . "Fish")
               (color . catppuccin-mocha-crust)))
    (id . shell-fish)))

(define glyph-shell-bash
  `((sections ((background . catppuccin-latte-subtext1) (text . "Shell")
               (color . catppuccin-latte-base)
               (logo . hashtag))
              ((background . catppuccin-latte-green) (text . "Bash")
               (color . catppuccin-mocha-crust)))
    (id . shell-bash)))

(define glyph-shell-eshell
  `((sections ((background . catppuccin-latte-subtext1) (text . "Shell")
               (color . catppuccin-latte-base)
               (logo . hashtag))
              ((background . catppuccin-latte-pink) (text . "EShell")
               (color . catppuccin-mocha-crust)))
    (id . shell-eshell)))

(define glyph-gnu-artanis
  `((sections ((background . catppuccin-latte-subtext1) (text . "GNU")
               (color . catppuccin-latte-base)
               (logo . lambda))
              ((background . catppuccin-latte-maroon) (text . "Artanis")
               (color . catppuccin-mocha-crust)))
    (id . gnu-artanis)))

(define glyph-gnu-artanis-122
  `((sections ((background . catppuccin-latte-subtext1) (text . "GNU")
               (color . catppuccin-latte-base)
               (logo . lambda)
               (font-weight . 900))
              ((background . catppuccin-latte-maroon) (text . "Artanis")
               (color . catppuccin-mocha-crust)
               (font-weight . 900))
              ((background . catppuccin-latte-subtext1) (text . "v1.2.2")
               (color . catppuccin-latte-base)
               (font-weight . 900)))
    (id . gnu-artanis-122)))

(define glyph-css-tailwind4
  `((sections ((background . catppuccin-latte-subtext1) (text . "CSS")
               (color . catppuccin-latte-base)
               (logo . paint))
              ((background . catppuccin-latte-sapphire) (text . "Tailwind v4")
               (color . catppuccin-mocha-crust)))
    (id . css-tailwind4)))

(define glyph-scala-213
  `((sections ((background . catppuccin-latte-subtext1) (text . "Scala")
               (color . catppuccin-latte-base)
               (logo . scala))
              ((background . catppuccin-latte-red) (text . "v2.13")
               (color . catppuccin-latte-base)))
    (id . scala-213)))

(define glyph-jointhefreeworld-org
  `((sections ((background . catppuccin-latte-subtext1) (text . "jointhefreeworld.org")
               (color . catppuccin-latte-base)
               (logo . gear)))
    (id . jointhefreeworld-org)))


(define glyph-sbt
  `((sections ((background . catppuccin-latte-subtext1) (text . "build")
               (color . catppuccin-latte-base)
               (logo . gear))
              ((background . catppuccin-latte-red) (text . "sbt")
               (color . catppuccin-latte-base)))
    (id . sbt)))

(define glyph-rust-185+
  `((sections ((background . catppuccin-latte-subtext1) (text . "Rust")
               (color . catppuccin-latte-base)
               (logo . rust))
              ((background . catppuccin-latte-peach) (text . "1.85+")
               (color . catppuccin-mocha-crust)))
    (id . rust-185+)))

(define glyph-cargo
  `((sections ((background . catppuccin-latte-subtext1) (text . "build")
               (color . catppuccin-latte-base)
               (logo . rust))
              ((background . catppuccin-latte-peach) (text . "cargo")
               (color . catppuccin-mocha-crust)))
    (id . cargo)))

(define glyph-justfile
  `((sections ((background . catppuccin-latte-subtext1) (text . "Justfile")
               (color . catppuccin-latte-base)
               (logo . gear)))
    (id . justfile)))

(define glyph-env
  `((sections ((background . catppuccin-latte-subtext1) (text . ".env")
               (color . catppuccin-latte-base)
               (logo . gear)))
    (id . env)))

(define glyph-java-25
  `((sections ((background . catppuccin-latte-subtext1) (text . "Java")
               (color . catppuccin-latte-base)
               (logo . java))
              ((background . catppuccin-latte-red) (text . "OpenJDK 25")
               (color . catppuccin-latte-base)))
    (id . java-25)))

(define glyph-kotlin-2
  `((sections ((background . catppuccin-latte-subtext1) (text . "Kotlin")
               (color . catppuccin-latte-base)
               (logo . code))
              ((background . catppuccin-latte-mauve) (text . "v2.0+")
               (color . catppuccin-latte-base)))
    (id . kotlin-2)))

(define glyph-scala-3
  `((sections ((background . catppuccin-latte-subtext1) (text . "Scala")
               (color . catppuccin-latte-base)
               (logo . scala))
              ((background . catppuccin-latte-maroon) (text . "v3.x")
               (color . catppuccin-mocha-crust)))
    (id . scala-3)))

(define glyph-build-gradle
  `((sections ((background . catppuccin-latte-subtext1) (text . "build")
               (color . catppuccin-latte-base)
               (logo . gear))
              ((background . catppuccin-latte-teal) (text . "Gradle")
               (color . catppuccin-mocha-crust)))
    (id . build-gradle)))

(define glyph-build-maven
  `((sections ((background . catppuccin-latte-subtext1) (text . "build")
               (color . catppuccin-latte-base)
               (logo . gear))
              ((background . catppuccin-latte-red) (text . "Maven")
               (color . catppuccin-latte-base)))
    (id . build-maven)))

(define glyph-lisp-sbcl
  `((sections ((background . catppuccin-latte-subtext1) (text . "Lisp")
               (color . catppuccin-latte-base)
               (logo . lambda))
              ((background . catppuccin-latte-maroon) (text . "SBCL")
               (color . catppuccin-mocha-crust)))
    (id . lisp-sbcl)))

(define glyph-scheme-racket
  `((sections ((background . catppuccin-latte-subtext1) (text . "Scheme")
               (color . catppuccin-latte-base)
               (logo . lambda))
              ((background . catppuccin-latte-blue) (text . "Racket")
               (color . "#ffffff")))
    (id . scheme-racket)))

(define glyph-clojure
  `((sections ((background . catppuccin-latte-subtext1) (text . "Lisp")
               (color . catppuccin-latte-base)
               (logo . lambda))
              ((background . catppuccin-latte-green) (text . "Clojure")
               (color . catppuccin-mocha-crust)))
    (id . clojure)))

(define glyph-emacs-org
  `((sections ((background . catppuccin-latte-subtext1) (text . "Emacs")
               (color . catppuccin-latte-base)
               (logo . emacs))
              ((background . catppuccin-latte-teal) (text . "Org-mode")
               (color . catppuccin-mocha-crust)))
    (id . emacs-org)))

(define glyph-emacs-magit
  `((sections ((background . catppuccin-latte-subtext1) (text . "Emacs")
               (color . catppuccin-latte-base)
               (logo . emacs))
              ((background . catppuccin-latte-red) (text . "Magit")
               (color . catppuccin-latte-base)))
    (id . emacs-magit)))

(define glyph-dev-docker
  `((sections ((background . catppuccin-latte-subtext1) (text . "Docker")
               (color . catppuccin-latte-base)
               (logo . cube))
              ((background . catppuccin-latte-blue) (text . "ready")
               (color . "#ffffff")))
    (id . dev-docker)))

(define glyph-nix-flake
  `((sections ((background . catppuccin-latte-subtext1) (text . "Nix")
               (color . catppuccin-latte-base)
               (logo . snowflake))
              ((background . catppuccin-latte-sapphire) (text . "flake")
               (color . catppuccin-mocha-crust)))
    (id . nix-flake)))

(define glyph-lang-c
  `((sections ((background . catppuccin-latte-subtext1) (text . "C")
               (color . catppuccin-latte-base)
               (logo . code))
              ((background . catppuccin-latte-blue) (text . "17")
               (color . "#ffffff")))
    (id . lang-c)))

(define glyph-gtk4
  `((sections ((background . catppuccin-latte-subtext1) (text . "GTK")
               (color . catppuccin-latte-base)
               (logo . gear))
              ((background . catppuccin-latte-blue) (text . "v4")
               (color . "#ffffff")))
    (id . gtk4)))

(define glyph-build-meson
  `((sections ((background . catppuccin-latte-subtext1) (text . "build")
               (color . catppuccin-latte-base)
               (logo . gear))
              ((background . catppuccin-latte-teal) (text . "Meson")
               (color . catppuccin-mocha-crust)))
    (id . build-meson)))

(define glyph-lang-python
  `((sections ((background . catppuccin-latte-subtext1) (text . "Python")
               (color . catppuccin-latte-base)
               (logo . python))
              ((background . catppuccin-latte-blue) (text . "3.13")
               (color . "#ffffff")))
    (id . lang-python)))

(define glyph-lang-go
  `((sections ((background . catppuccin-latte-subtext1) (text . "Go")
               (color . catppuccin-latte-base)
               (logo . go))
              ((background . catppuccin-latte-sky) (text . "1.24")
               (color . catppuccin-mocha-crust)))
    (id . lang-go)))

(define glyph-build-cmake
  `((sections ((background . catppuccin-latte-subtext1) (text . "build")
               (color . catppuccin-latte-base)
               (logo . cmake))
              ((background . catppuccin-latte-blue) (text . "CMake")
               (color . "#ffffff")))
    (id . build-cmake)))

(define glyph-pkg-homebrew
  `((sections ((background . catppuccin-latte-subtext1) (text . "pkg")
               (color . catppuccin-latte-base)
               (logo . homebrew))
              ((background . catppuccin-latte-yellow) (text . "Homebrew")
               (color . catppuccin-mocha-crust)))
    (id . pkg-homebrew)))

(define glyph-ci-buildkite
  `((sections ((background . catppuccin-latte-subtext1) (text . "CI")
               (color . catppuccin-latte-base)
               (logo . buildkite))
              ((background . catppuccin-latte-green) (text . "Buildkite")
               (color . catppuccin-mocha-crust)))
    (id . ci-buildkite)))

(define glyph-ci-drone
  `((sections ((background . catppuccin-latte-subtext1) (text . "CI")
               (color . catppuccin-latte-base)
               (logo . drone))
              ((background . catppuccin-latte-sky) (text . "Drone")
               (color . catppuccin-mocha-crust)))
    (id . ci-drone)))

(define glyph-ci-travis
  `((sections ((background . catppuccin-latte-subtext1) (text . "CI")
               (color . catppuccin-latte-base)
               (logo . travisci))
              ((background . catppuccin-latte-maroon) (text . "Travis CI")
               (color . catppuccin-mocha-crust)))
    (id . ci-travis)))

(define glyph-test-jest
  `((sections ((background . catppuccin-latte-subtext1) (text . "test")
               (color . catppuccin-latte-base)
               (logo . jest))
              ((background . catppuccin-latte-red) (text . "Jest")
               (color . catppuccin-latte-base)))
    (id . test-jest)))

(define glyph-test-vitest
  `((sections ((background . catppuccin-latte-subtext1) (text . "test")
               (color . catppuccin-latte-base)
               (logo . vitest))
              ((background . catppuccin-latte-green) (text . "Vitest")
               (color . catppuccin-mocha-crust)))
    (id . test-vitest)))

(define glyph-test-pytest
  `((sections ((background . catppuccin-latte-subtext1) (text . "test")
               (color . catppuccin-latte-base)
               (logo . pytest))
              ((background . catppuccin-latte-sky) (text . "pytest")
               (color . catppuccin-mocha-crust)))
    (id . test-pytest)))

(define glyph-lint-eslint
  `((sections ((background . catppuccin-latte-subtext1) (text . "lint")
               (color . catppuccin-latte-base)
               (logo . eslint))
              ((background . catppuccin-latte-lavender) (text . "ESLint")
               (color . catppuccin-mocha-crust)))
    (id . lint-eslint)))

(define glyph-fmt-prettier
  `((sections ((background . catppuccin-latte-subtext1) (text . "format")
               (color . catppuccin-latte-base)
               (logo . prettier))
              ((background . catppuccin-latte-yellow) (text . "Prettier")
               (color . catppuccin-mocha-crust)))
    (id . fmt-prettier)))

(define glyph-db-postgresql
  `((sections ((background . catppuccin-latte-subtext1) (text . "db")
               (color . catppuccin-latte-base)
               (logo . postgresql))
              ((background . catppuccin-latte-blue) (text . "PostgreSQL")
               (color . "#ffffff")))
    (id . db-postgresql)))

(define glyph-db-sqlite
  `((sections ((background . catppuccin-latte-subtext1) (text . "db")
               (color . catppuccin-latte-base)
               (logo . sqlite))
              ((background . catppuccin-latte-sapphire) (text . "SQLite")
               (color . catppuccin-mocha-crust)))
    (id . db-sqlite)))

(define glyph-db-redis
  `((sections ((background . catppuccin-latte-subtext1) (text . "db")
               (color . catppuccin-latte-base)
               (logo . redis))
              ((background . catppuccin-latte-red) (text . "Redis")
               (color . catppuccin-latte-base)))
    (id . db-redis)))

(define glyph-deploy-kubernetes
  `((sections ((background . catppuccin-latte-subtext1) (text . "deploy")
               (color . catppuccin-latte-base)
               (logo . kubernetes))
              ((background . catppuccin-latte-blue) (text . "Kubernetes")
               (color . "#ffffff")))
    (id . deploy-kubernetes)))

(define glyph-infra-terraform
  `((sections ((background . catppuccin-latte-subtext1) (text . "infra")
               (color . catppuccin-latte-base)
               (logo . terraform))
              ((background . catppuccin-latte-mauve) (text . "Terraform")
               (color . catppuccin-latte-base)))
    (id . infra-terraform)))

(define glyph-web-nginx
  `((sections ((background . catppuccin-latte-subtext1) (text . "server")
               (color . catppuccin-latte-base)
               (logo . nginx))
              ((background . catppuccin-latte-green) (text . "NGINX")
               (color . catppuccin-mocha-crust)))
    (id . web-nginx)))

(define glyph-shell-zsh
  `((sections ((background . catppuccin-latte-subtext1) (text . "Shell")
               (color . catppuccin-latte-base)
               (logo . zsh))
              ((background . catppuccin-latte-peach) (text . "Zsh")
               (color . catppuccin-mocha-crust)))
    (id . shell-zsh)))

(define glyph-docs-markdown
  `((sections ((background . catppuccin-latte-subtext1) (text . "docs")
               (color . catppuccin-latte-base)
               (logo . markdown))
              ((background . catppuccin-latte-flamingo) (text . "Markdown")
               (color . catppuccin-mocha-crust)))
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