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
  `((sections ((background . "#555") (text . "pipeline")
               (color . "#fff"))
              ((background . "#407430") (text . "succeeded")
               (color . "#fff")))
    (id . pipeline-succeeded)))

(define glyph-gnu-guix
  `((sections ((background . "#555") (text . "GNU")
               (color . "#fff")
               (logo . gnu))
              ((background . "#FFBF01") (text . "Guix")
               (color . "#000")))
    (id . gnu-guix)))

(define glyph-scheme-guile
  `((sections ((background . "#555") (text . "Scheme")
               (color . "#fff")
               (logo . lambda))
              ((background . "#d0730f") (text . "Guile")
               (color . "#fff")))
    (id . scheme-guile)))

(define glyph-haskell-ghc910
  `((sections ((background "#555")
               (text . "Haskell")
               (color . "#fff")
               (logo . lambda))
              ((background . "#7851A9") (text . "GHC 9.10")
               (color . "#fff")))
    (id . haskell-ghc910)))

(define glyph-gnu-make
  `((sections ((background . "#555") (text . "GNU")
               (color . "#fff")
               (logo . gnu))
              ((background . "#a32d2a") (text . "Make")
               (color . "#fff")))
    (id . gnu-make)))

(define glyph-maak
  `((sections ((background . "#555") (text . "Maak")
               (color . "#fff")
               (logo . lambda)))
    (id . maak)))

(define glyph-i18n-gnu-gettext
  `((sections ((background . "#555") (text . "i18n")
               (color . "#fff")
               (logo . language))
              ((background . "#a32d2a") (text . "GNU gettext")
               (color . "#fff")))
    (id . i18n-gnu-gettext)))

(define glyph-gnu-emacs
  `((sections ((background . "#555") (text . "GNU")
               (color . "#fff")
               (logo . emacs))
              ((background . "#c4609e") (text . "Emacs")
               (color . "#fff")))
    (id . gnu-emacs)))

(define glyph-gnu-emacs-single
  `((sections ((background . "#555") (text . "GNU Emacs")
               (color . "#fff")
               (logo . emacs)))
    (id . gnu-emacs-single)))

(define glyph-emacs-lisp
  `((sections ((background . "#555") (text . "Emacs")
               (color . "#fff")
               (logo . emacs))
              ((background . "#c4609e") (text . "Lisp")
               (color . "#fff")))
    (id . emacs-lisp)))

(define glyph-license-gpl3+
  `((sections ((background . "#555") (text . "license")
               (color . "#fff")
               (logo . scales))
              ((background . "#4f677f") (text . "GPL v3+")
               (color . "#fff")))
    (id . license-gpl3+)))

(define glyph-license-lgpl3+
  `((sections ((background . "#555") (text . "license")
               (color . "#fff")
               (logo . scales))
              ((background . "#4f677f") (text . "LGPL v3+")
               (color . "#fff")))
    (id . license-lgpl3+)))

(define glyph-license-agpl3+
  `((sections ((background . "#555") (text . "license")
               (color . "#fff")
               (logo . scales))
              ((background . "#4f677f") (text . "AGPL v3+")
               (color . "#fff")))
    (id . license-agpl3+)))

(define glyph-license-fdl13+
  `((sections ((background . "#555") (text . "license")
               (color . "#fff")
               (logo . scales))
              ((background . "#4f677f") (text . "GFDL v1.3+")
               (color . "#fff")))
    (id . license-fdl13+)))

(define glyph-shell-fish
  `((sections ((background . "#555") (text . "Shell")
               (color . "#fff")
               (logo . hashtag))
              ((background . "#407430") (text . "Fish")
               (color . "#fff")))
    (id . shell-fish)))

(define glyph-shell-bash
  `((sections ((background . "#555") (text . "Shell")
               (color . "#fff")
               (logo . hashtag))
              ((background . "#407430") (text . "Bash")
               (color . "#fff")))
    (id . shell-bash)))

(define glyph-shell-eshell
  `((sections ((background . "#555") (text . "Shell")
               (color . "#fff")
               (logo . hashtag))
              ((background . "#c4609e") (text . "EShell")
               (color . "#fff")))
    (id . shell-eshell)))

(define glyph-gnu-artanis
  `((sections ((background . "#555") (text . "GNU")
               (color . "#fff")
               (logo . lambda))
              ((background . "#5a3142") (text . "Artanis")
               (color . "#fff")))
    (id . gnu-artanis)))

(define glyph-gnu-artanis-122
  `((sections ((background . "#555") (text . "GNU")
               (color . "#fff")
               (logo . lambda)
               (font-weight . 900))
              ((background . "#5a3142") (text . "Artanis")
               (color . "#fff")
               (font-weight . 900))
              ((background . "#555") (text . "v1.2.2")
               (color . "#fff")
               (font-weight . 900)))
    (id . gnu-artanis-122)))

(define glyph-css-tailwind4
  `((sections ((background . "#555") (text . "CSS")
               (color . "#fff")
               (logo . paint))
              ((background . "#80aadf") (text . "Tailwind v4")
               (color . "#111")))
    (id . css-tailwind4)))

(define glyph-scala-213
  `((sections ((background . "#555") (text . "Scala")
               (color . "#fff")
               (logo . scala))
              ((background . "#A50021") (text . "v2.13")
               (color . "#fff")))
    (id . scala-213)))

(define glyph-jointhefreeworld-org
  `((sections ((background . "#555") (text . "jointhefreeworld.org")
               (color . "#fff")
               (logo . gear)))
    (id . jointhefreeworld-org)))


(define glyph-sbt
  `((sections ((background . "#555") (text . "build")
               (color . "#fff")
               (logo . gear))
              ((background . "#A50021") (text . "sbt")
               (color . "#fff")))
    (id . sbt)))

(define glyph-rust-185+
  `((sections ((background . "#555") (text . "Rust")
               (color . "#fff")
               (logo . rust))
              ((background . "#e89444") (text . "1.85+")
               (color . "#000")))
    (id . rust-185+)))

(define glyph-cargo
  `((sections ((background . "#555") (text . "build")
               (color . "#fff")
               (logo . rust))
              ((background . "#e89444") (text . "cargo")
               (color . "#000")))
    (id . cargo)))

(define glyph-justfile
  `((sections ((background . "#555") (text . "Justfile")
               (color . "#fff")
               (logo . gear)))
    (id . justfile)))

(define glyph-env
  `((sections ((background . "#555") (text . ".env")
               (color . "#fff")
               (logo . gear)))
    (id . env)))

(define glyph-java-25
  `((sections ((background . "#555") (text . "Java")
               (color . "#fff")
               (logo . java))
              ((background . "#ea2d2e") (text . "OpenJDK 25")
               (color . "#fff")))
    (id . java-25)))

(define glyph-kotlin-2
  `((sections ((background . "#555") (text . "Kotlin")
               (color . "#fff")
               (logo . code))
              ((background . "#7F52FF") (text . "v2.0+")
               (color . "#fff")))
    (id . kotlin-2)))

(define glyph-scala-3
  `((sections ((background . "#555") (text . "Scala")
               (color . "#fff")
               (logo . scala))
              ((background . "#DE3423") (text . "v3.x")
               (color . "#fff")))
    (id . scala-3)))

(define glyph-build-gradle
  `((sections ((background . "#555") (text . "build")
               (color . "#fff")
               (logo . gear))
              ((background . "#02303a") (text . "Gradle")
               (color . "#fff")))
    (id . build-gradle)))

(define glyph-build-maven
  `((sections ((background . "#555") (text . "build")
               (color . "#fff")
               (logo . gear))
              ((background . "#c71a36") (text . "Maven")
               (color . "#fff")))
    (id . build-maven)))

(define glyph-lisp-sbcl
  `((sections ((background . "#555") (text . "Lisp")
               (color . "#fff")
               (logo . lambda))
              ((background . "#e15639") (text . "SBCL")
               (color . "#fff")))
    (id . lisp-sbcl)))

(define glyph-scheme-racket
  `((sections ((background . "#555") (text . "Scheme")
               (color . "#fff")
               (logo . lambda))
              ((background . "#3c5c99") (text . "Racket")
               (color . "#fff")))
    (id . scheme-racket)))

(define glyph-clojure
  `((sections ((background . "#555") (text . "Lisp")
               (color . "#fff")
               (logo . lambda))
              ((background . "#63b132") (text . "Clojure")
               (color . "#fff")))
    (id . clojure)))

(define glyph-emacs-org
  `((sections ((background . "#555") (text . "Emacs")
               (color . "#fff")
               (logo . emacs))
              ((background . "#77aa99") (text . "Org-mode")
               (color . "#fff")))
    (id . emacs-org)))

(define glyph-emacs-magit
  `((sections ((background . "#555") (text . "Emacs")
               (color . "#fff")
               (logo . emacs))
              ((background . "#aa2233") (text . "Magit")
               (color . "#fff")))
    (id . emacs-magit)))

(define glyph-dev-docker
  `((sections ((background . "#555") (text . "Docker")
               (color . "#fff")
               (logo . cube))
              ((background . "#2496ed") (text . "ready")
               (color . "#fff")))
    (id . dev-docker)))

(define glyph-nix-flake
  `((sections ((background . "#555") (text . "Nix")
               (color . "#fff")
               (logo . snowflake))
              ((background . "#5277c3") (text . "flake")
               (color . "#fff")))
    (id . nix-flake)))

(define glyph-lang-c
  `((sections ((background . "#555") (text . "C")
               (color . "#fff")
               (logo . code))
              ((background . "#00599C") (text . "C17")
               (color . "#fff")))
    (id . lang-c)))

(define glyph-gtk4
  `((sections ((background . "#555") (text . "GTK")
               (color . "#fff")
               (logo . gear))
              ((background . "#3584e4") (text . "v4.x")
               (color . "#fff")))
    (id . gtk4)))

(define glyph-build-meson
  `((sections ((background . "#555") (text . "build")
               (color . "#fff")
               (logo . gear))
              ((background . "#008080") (text . "Meson")
               (color . "#fff")))
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
