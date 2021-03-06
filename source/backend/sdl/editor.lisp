;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(in-package :projectured)

;;;;;;
;;; Editor

(def class* editor/sdl (editor)
  ())

;;;;;;
;;; Construction

(def method make-editor (&key (width 1280) (height 720) (filename nil))
  (declare (ignorable filename))
  (make-instance 'editor/sdl
                 :devices (append (list (make-instance 'device/mouse)
                                        (make-instance 'device/keyboard)
                                        (make-device/display/sdl width height))
                                  (when filename
                                    (list (make-device/file/sdl filename))))
                 :event-queue (make-instance 'event-queue :events nil)
                 :gesture-queue (make-instance 'gesture-queue :gestures nil)))

;;;;;;
;;; API

(def method run-read-evaluate-print-loop ((editor editor/sdl) document projection &key measure measure-reader measure-evaluator measure-printer)
  (unwind-protect
       (progn
         (sdl:init-sdl)
         (sdl-image:init-image :jpg :png :tif)
         (sdl:initialise-default-font (make-instance 'sdl:ttf-font-definition :size 18 :filename (resource-pathname "font/UbuntuMono-R.ttf")))
         (sdl:init-video)
         (bind ((display (find-if (of-type 'device/display) (devices-of editor))))
           (if display
               (bind ((surface (sdl:window (width-of display) (height-of display) :flags sdl-cffi::sdl-no-frame :double-buffer #t :title-caption "Projectional Editor")))
                 (setf (surface-of display) surface)
                 (sdl:fill-surface sdl:*white* :surface surface)
                 (call-next-method))
               (call-next-method))))
    (sdl:quit-video)))

(def method print-to-devices :around ((editor editor/sdl) document projection)
  (bind ((display (find-if (of-type 'device/display) (devices-of editor))))
    (if display
        (sdl:with-surface ((surface-of display))
          (sdl:fill-surface sdl:*white*) ;; KLUDGE
          (call-next-method)
          (when sdl:*default-display*
            (sdl:update-display)))
        (call-next-method))))

;; KLUDGE: what shall we dispatch on here? this is obviously wrong...
(def method read-event ((devices sequence))
  (bind ((sdl:*sdl-event* (sdl:new-event)))
    (sdl:enable-unicode)
    (sdl-cffi::sdl-wait-event sdl:*sdl-event*)
    #+nil ;; TODO: poll or wait?
    (sdl-cffi::sdl-poll-event sdl:*sdl-event*)
    (prog1
        (case (sdl:event-type sdl:*sdl-event*)
          (:idle
           (values))
          (:quit-event
           (make-instance 'event/window/quit
                          :location (make-2d (sdl:mouse-x) (sdl:mouse-y))))
          (:key-down-event
           (sdl:with-key-down-event ((mod-key :mod-key) (key :key) (character :unicode)) sdl:*sdl-event*
             (make-instance 'event/keyboard/key-down
                            :timestamp (get-internal-real-time)
                            :modifiers (modifier-keys mod-key)
                            :location (make-2d (sdl:mouse-x) (sdl:mouse-y))
                            :key key
                            :character (unless (zerop character) (code-char character)))))
          (:key-up-event
           (sdl:with-key-up-event ((mod-key :mod-key) (key :key) (character :unicode)) sdl:*sdl-event*
             (make-instance 'event/keyboard/key-up
                            :timestamp (get-internal-real-time)
                            :modifiers (modifier-keys mod-key)
                            :location (make-2d (sdl:mouse-x) (sdl:mouse-y))
                            :key key
                            :character (unless (zerop character) (code-char character)))))
          (:mouse-motion-event
           (sdl:with-mouse-motion-event ((x :x) (y :y)) sdl:*sdl-event*
             (make-instance 'event/mouse/move
                            :timestamp (get-internal-real-time)
                            :modifiers (modifier-keys (sdl:get-mods-state))
                            :location (make-2d x y))))
          (:mouse-button-down-event
           (sdl:with-mouse-button-down-event ((x :x) (y :y) (button :button)) sdl:*sdl-event*
             (make-instance 'event/mouse/button/press
                            :timestamp (get-internal-real-time)
                            :modifiers (modifier-keys (sdl:get-mods-state))
                            :button (mouse-button button)
                            :location (make-2d x y))))
          (:mouse-button-up-event
           (sdl:with-mouse-button-up-event ((x :x) (y :y) (button :button)) sdl:*sdl-event*
             (make-instance 'event/mouse/button/release
                            :timestamp (get-internal-real-time)
                            :modifiers (modifier-keys (sdl:get-mods-state))
                            :button (mouse-button button)
                            :location (make-2d x y))))
          (:video-resize-event
           ;; TODO:
           (values))
          (:video-expose-event
           (sdl:update-display)))
      (sdl:free-event sdl:*sdl-event*))))

(def function mouse-button (button)
  (cond ((= sdl::mouse-left button)
         :button-left)
        ((= sdl::mouse-middle button)
         :button-middle)
        ((= sdl::mouse-right button)
         :button-right)
        ((= sdl::mouse-wheel-down button)
         :wheel-down)
        ((= sdl::mouse-wheel-up button)
         :wheel-up)))

(def function modifier-keys (keys)
  (remove nil (mapcar 'modifier-key keys)))

(def function modifier-key (key)
  (ecase key
    ((:sdl-key-mod-lctrl :sdl-key-mod-rctrl) :control)
    ((:sdl-key-mod-lshift :sdl-key-mod-rshift) :shift)
    ((:sdl-key-mod-lalt :sdl-key-mod-ralt) :alt)
    ((:sdl-key-mod-num) nil)))
