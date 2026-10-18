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

(define-module (ggg config)
  #:declarative? #t)

(define glyph-pipeline-succeeded
  `((sections ((background . badge-gray) (text . "pipeline")
               (color . white))
              ((background . success-green) (text . "succeeded")
               (color . white)))
    (id . pipeline-succeeded)))

(define glyph-gnu-guix
  `((sections ((background . badge-gray) (text . "GNU")
               (color . white)
               (logo . gnu))
              ((background . guix-yellow) (text . "Guix")
               (color . black)))
    (id . gnu-guix)))

(define glyph-scheme-guile
  `((sections ((background . badge-gray) (text . "Scheme")
               (color . white)
               (logo . lambda))
              ((background . guix-orange) (text . "Guile")
               (color . white)))
    (id . scheme-guile)))

(define glyph-haskell-ghc910
  `((sections ((background . badge-gray)
               (text . "Haskell")
               (color . white)
               (logo . lambda))
              ((background . haskell-purple) (text . "GHC 9.10")
               (color . white)))
    (id . haskell-ghc910)))

(define glyph-gnu-make
  `((sections ((background . badge-gray) (text . "GNU")
               (color . white)
               (logo . gnu))
              ((background . gnu-red) (text . "Make")
               (color . white)))
    (id . gnu-make)))

(define glyph-maak
  `((sections ((background . badge-gray) (text . "Maak")
               (color . white)
               (logo . lambda)))
    (id . maak)))

(define glyph-i18n-gnu-gettext
  `((sections ((background . badge-gray) (text . "i18n")
               (color . white)
               (logo . language))
              ((background . gnu-red) (text . "GNU gettext")
               (color . white)))
    (id . i18n-gnu-gettext)))

(define glyph-gnu-emacs
  `((sections ((background . badge-gray) (text . "GNU")
               (color . white)
               (logo . emacs))
              ((background . emacs-magenta) (text . "Emacs")
               (color . white)))
    (id . gnu-emacs)))

(define glyph-gnu-emacs-single
  `((sections ((background . badge-gray) (text . "GNU Emacs")
               (color . white)
               (logo . emacs)))
    (id . gnu-emacs-single)))

(define glyph-emacs-lisp
  `((sections ((background . badge-gray) (text . "Emacs")
               (color . white)
               (logo . emacs))
              ((background . emacs-magenta) (text . "Lisp")
               (color . white)))
    (id . emacs-lisp)))

(define glyph-license-gpl3+
  `((sections ((background . badge-gray) (text . "license")
               (color . white)
               (logo . scales))
              ((background . license-steel) (text . "GPL v3+")
               (color . white)))
    (id . license-gpl3+)))

(define glyph-license-lgpl3+
  `((sections ((background . badge-gray) (text . "license")
               (color . white)
               (logo . scales))
              ((background . license-steel) (text . "LGPL v3+")
               (color . white)))
    (id . license-lgpl3+)))

(define glyph-license-agpl3+
  `((sections ((background . badge-gray) (text . "license")
               (color . white)
               (logo . scales))
              ((background . license-steel) (text . "AGPL v3+")
               (color . white)))
    (id . license-agpl3+)))

(define glyph-license-fdl13+
  `((sections ((background . badge-gray) (text . "license")
               (color . white)
               (logo . scales))
              ((background . license-steel) (text . "GFDL v1.3+")
               (color . white)))
    (id . license-fdl13+)))

(define glyph-shell-fish
  `((sections ((background . badge-gray) (text . "Shell")
               (color . white)
               (logo . hashtag))
              ((background . success-green) (text . "Fish")
               (color . white)))
    (id . shell-fish)))

(define glyph-shell-bash
  `((sections ((background . badge-gray) (text . "Shell")
               (color . white)
               (logo . hashtag))
              ((background . success-green) (text . "Bash")
               (color . white)))
    (id . shell-bash)))

(define glyph-shell-eshell
  `((sections ((background . badge-gray) (text . "Shell")
               (color . white)
               (logo . hashtag))
              ((background . emacs-magenta) (text . "EShell")
               (color . white)))
    (id . shell-eshell)))

(define glyph-gnu-artanis
  `((sections ((background . badge-gray) (text . "GNU")
               (color . white)
               (logo . lambda))
              ((background . artanis-plum) (text . "Artanis")
               (color . white)))
    (id . gnu-artanis)))

(define glyph-gnu-artanis-122
  `((sections ((background . badge-gray) (text . "GNU")
               (color . white)
               (logo . lambda)
               (font-weight . 900))
              ((background . artanis-plum) (text . "Artanis")
               (color . white)
               (font-weight . 900))
              ((background . badge-gray) (text . "v1.2.2")
               (color . white)
               (font-weight . 900)))
    (id . gnu-artanis-122)))

(define glyph-css-tailwind4
  `((sections ((background . badge-gray) (text . "CSS")
               (color . white)
               (logo . paint))
              ((background . tailwind-blue) (text . "Tailwind v4")
               (color . graphite)))
    (id . css-tailwind4)))

(define glyph-scala-213
  `((sections ((background . badge-gray) (text . "Scala")
               (color . white)
               (logo . scala))
              ((background . scala-red) (text . "v2.13")
               (color . white)))
    (id . scala-213)))

(define glyph-jointhefreeworld-org
  `((sections ((background . badge-gray) (text . "jointhefreeworld.org")
               (color . white)
               (logo . gear)))
    (id . jointhefreeworld-org)))


(define glyph-sbt
  `((sections ((background . badge-gray) (text . "build")
               (color . white)
               (logo . gear))
              ((background . scala-red) (text . "sbt")
               (color . white)))
    (id . sbt)))

(define glyph-rust-185+
  `((sections ((background . badge-gray) (text . "Rust")
               (color . white)
               (logo . rust))
              ((background . rust-orange) (text . "1.85+")
               (color . black)))
    (id . rust-185+)))

(define glyph-cargo
  `((sections ((background . badge-gray) (text . "build")
               (color . white)
               (logo . rust))
              ((background . rust-orange) (text . "cargo")
               (color . black)))
    (id . cargo)))

(define glyph-justfile
  `((sections ((background . badge-gray) (text . "Justfile")
               (color . white)
               (logo . gear)))
    (id . justfile)))

(define glyph-env
  `((sections ((background . badge-gray) (text . ".env")
               (color . white)
               (logo . gear)))
    (id . env)))

(define glyph-java-25
  `((sections ((background . badge-gray) (text . "Java")
               (color . white)
               (logo . java))
              ((background . java-red) (text . "OpenJDK 25")
               (color . white)))
    (id . java-25)))

(define glyph-kotlin-2
  `((sections ((background . badge-gray) (text . "Kotlin")
               (color . white)
               (logo . code))
              ((background . kotlin-purple) (text . "v2.0+")
               (color . white)))
    (id . kotlin-2)))

(define glyph-scala-3
  `((sections ((background . badge-gray) (text . "Scala")
               (color . white)
               (logo . scala))
              ((background . scala3-red) (text . "v3.x")
               (color . white)))
    (id . scala-3)))

(define glyph-build-gradle
  `((sections ((background . badge-gray) (text . "build")
               (color . white)
               (logo . gear))
              ((background . gradle-teal) (text . "Gradle")
               (color . white)))
    (id . build-gradle)))

(define glyph-build-maven
  `((sections ((background . badge-gray) (text . "build")
               (color . white)
               (logo . gear))
              ((background . maven-red) (text . "Maven")
               (color . white)))
    (id . build-maven)))

(define glyph-lisp-sbcl
  `((sections ((background . badge-gray) (text . "Lisp")
               (color . white)
               (logo . lambda))
              ((background . sbcl-orange) (text . "SBCL")
               (color . white)))
    (id . lisp-sbcl)))

(define glyph-scheme-racket
  `((sections ((background . badge-gray) (text . "Scheme")
               (color . white)
               (logo . lambda))
              ((background . racket-blue) (text . "Racket")
               (color . white)))
    (id . scheme-racket)))

(define glyph-clojure
  `((sections ((background . badge-gray) (text . "Lisp")
               (color . white)
               (logo . lambda))
              ((background . clojure-green) (text . "Clojure")
               (color . white)))
    (id . clojure)))

(define glyph-emacs-org
  `((sections ((background . badge-gray) (text . "Emacs")
               (color . white)
               (logo . emacs))
              ((background . org-green) (text . "Org-mode")
               (color . white)))
    (id . emacs-org)))

(define glyph-emacs-magit
  `((sections ((background . badge-gray) (text . "Emacs")
               (color . white)
               (logo . emacs))
              ((background . magit-red) (text . "Magit")
               (color . white)))
    (id . emacs-magit)))

(define glyph-dev-docker
  `((sections ((background . badge-gray) (text . "Docker")
               (color . white)
               (logo . cube))
              ((background . docker-blue) (text . "ready")
               (color . white)))
    (id . dev-docker)))

(define glyph-nix-flake
  `((sections ((background . badge-gray) (text . "Nix")
               (color . white)
               (logo . snowflake))
              ((background . nix-blue) (text . "flake")
               (color . white)))
    (id . nix-flake)))

(define glyph-lang-c
  `((sections ((background . badge-gray) (text . "C")
               (color . white)
               (logo . code))
              ((background . gcc-blue) (text . "17")
               (color . white)))
    (id . lang-c)))

(define glyph-gtk4
  `((sections ((background . badge-gray) (text . "GTK")
               (color . white)
               (logo . gear))
              ((background . gtk-blue) (text . "v4")
               (color . white)))
    (id . gtk4)))

(define glyph-build-meson
  `((sections ((background . badge-gray) (text . "build")
               (color . white)
               (logo . gear))
              ((background . meson-teal) (text . "Meson")
               (color . white)))
    (id . build-meson)))

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
        glyph-env))
