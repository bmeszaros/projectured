;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(defsystem :projectured.sdl
  :defsystem-depends-on (:hu.dwim.asdf)
  :class "hu.dwim.asdf:hu.dwim.system"
  :package-name :projectured
  :description "The SDL backend for the generic purpose projectional editor."
  :depends-on (:lispbuilder-sdl-gfx
               :lispbuilder-sdl-image
               :lispbuilder-sdl-ttf
               :projectured)
  :components ((:module "source"
                :components ((:module "backend"
                              :components ((:module "sdl"
                                            :components ((:file "device")
                                                         (:file "editor" :depends-on ("device"))
                                                         (:file "graphics")
                                                         (:file "printer" :depends-on ("device"))))))))))
