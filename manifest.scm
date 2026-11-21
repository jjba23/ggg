;; ggg: guile glyph generator
;;
;; Spdx-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(use-modules (guix packages)
             (gnu)
             (gnu packages)
             (guix utils)
             (guix git-download)
             (guix download)
             (gnu packages admin)
             (gnu packages guile)
             (gnu packages nss)
             (gnu packages gnupg)
             (gnu packages guile-xyz)
             (gnu packages imagemagick)
             (gnu packages pkg-config)
             (guix build-system guile)
             (gnu packages linux)
             (gnu packages compression)
             (gnu packages texinfo)
             (gnu packages autotools)
             (gnu packages rust-apps)
             ((guix licenses)
              #:prefix license:))

(packages->manifest (list guile-3.0
                          imagemagick
                          watchexec
                          ;; The API documentation generator.  It is defined
                          ;; by the jointhefreeworld channel `channels.scm'
                          ;; pins, so it is resolved by name against the
                          ;; channels rather than imported from a module.
                          (specification->package "guile-dokgen")
                          (specification->package "texinfo")
                          guile-ares-rs))
