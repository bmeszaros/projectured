;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(in-package :projectured)

;;;;;;
;;; Document

(def document text/base ()
  ())

(def document text/element (text/base)
  ((font :type style/font)
   (font-color :type style/color)
   (fill-color :type style/color)
   (line-color :type style/color)
   (padding :type inset)))

(def document text/newline (text/element)
  ((content (string #\NewLine) :type string :allocation :class :computed-in nil)))

(def document text/spacing (text/element)
  ((size :type number)
   (unit :type (member :pixel :space))))

(def document text/string (text/element)
  ((content :type string)))

(def document text/text (text/base)
  ((elements :type sequence)))

;;;;;;
;;; Construction

(def function text/make-newline (&key font padding)
  (make-instance 'text/newline :font font :padding padding))

(def function text/make-spacing (size &key font font-color fill-color line-color (unit :pixel) padding)
  (make-instance 'text/spacing
                 :size size
                 :unit unit
                 :font font
                 :font-color font-color
                 :fill-color fill-color
                 :line-color line-color
                 :padding padding))

(def function text/make-string (content &key font font-color fill-color line-color padding)
  (check-type content string)
  (make-instance 'text/string
                 :content content
                 :font font
                 :font-color font-color
                 :fill-color fill-color
                 :line-color line-color
                 :padding padding))

(def function text/make-text (elements &key selection)
  (make-instance 'text/text :elements elements :selection selection))

;;;;;;
;;; Construction

(def macro text/newline (&key font padding)
  `(text/make-newline :font ,(or font '*font/default*) :padding ,padding))

(def macro text/spacing (size &key unit font font-color fill-color line-color padding)
  `(text/make-spacing ,size :unit ,unit :font ,(or font '*font/default*) :font-color ,font-color :fill-color ,fill-color :line-color ,line-color :padding ,padding))

(def macro text/string (content &key font font-color fill-color line-color padding)
  `(text/make-string ,content :font ,(or font '*font/default*) :font-color ,(or font-color '*color/default*) :fill-color ,fill-color :line-color ,line-color :padding ,padding))

(def macro text/text ((&key selection) &body elements)
  `(text/make-text (list ,@elements) :selection ,selection))

;;;;;;
;;; Construction

(def function text/make-simple-text (content &key selection (font *font/default*) (font-color *color/default*) fill-color line-color padding)
  (text/text (:selection selection)
    (text/string content :font font :font-color font-color :fill-color fill-color :line-color line-color :padding padding)))

(def function text/make-default-text (content default-content &key selection (font *font/default*) (font-color *color/default*) fill-color line-color padding)
  (text/text (:selection selection)
    (if (zerop (length content))
        (text/string default-content :font font :font-color (color/lighten font-color 0.75) :fill-color fill-color :line-color line-color :padding padding)
        (text/string content :font font :font-color font-color :fill-color fill-color :line-color line-color :padding padding))))
;;;;;;
;;; Operation

(def operation operation/text/base ()
  ())

(def operation operation/text/replace-range (operation/text/base)
  ((document :type text/text)
   (selection :type reference)
   (replacement :type text/text)))

;;;;;;
;;; Construction

(def function make-operation/text/replace-range (document selection replacement)
  (make-instance 'operation/text/replace-range
                 :document document
                 :selection selection
                 :replacement replacement))

;;;;;;
;;; Text API

(def structure (text/position (:constructor text/make-position))
  (element nil :type (or null non-negative-integer computed-ll))
  (index nil :type (or null non-negative-integer))
  (distance nil :type (or null integer)))

(def function text/position= (position-1 position-2)
  (or (bind ((distance-1 (text/position-distance position-1))
             (distance-2 (text/position-distance position-2)))
        (and distance-1 distance-2 (= distance-1 distance-2)))
      (bind ((element-1 (text/position-element position-1))
             (element-2 (text/position-element position-2))
             (index-1 (text/position-index position-1))
             (index-2 (text/position-index position-2)))
        (and (and element-1 element-2
                  (eql (text/position-element position-1)
                       (text/position-element position-2)))
             (and index-1 index-2
                  (= (text/position-index position-1)
                     (text/position-index position-2)))))))

(def function text/position< (text position-1 position-2)
  (iter (for position :initially (text/next-position text position-1) :then (text/next-position text position))
        (while position)
        (when (text/position= position position-2)
          (return #t))))

(def function text/position<= (text position-1 position-2)
  (or (text/position= position-1 position-2) (text/position< text position-1 position-2)))

(def function text/position> (text position-1 position-2)
  (iter (for position :initially (text/previous-position text position-1) :then (text/previous-position text position))
        (while position)
        (when (text/position= position position-2)
          (return #t))))

(def function text/position>= (text position-1 position-2)
  (or (text/position= position-1 position-2) (text/position> text position-1 position-2)))

(def function text/origin-position (text)
  (bind ((elements (elements-of text)))
    (etypecase elements
      (null nil)
      (computed-ll (text/make-position :element elements :index 0 :distance 0))
      (sequence (text/make-position :element 0 :index 0 :distance 0)))))

(def function text/first-position (text)
  (bind ((elements (elements-of text)))
    (etypecase elements
      (null nil)
      (computed-ll (text/make-position :element (first-element elements) :index 0 :distance nil))
      (sequence (text/make-position :element 0 :index 0 :distance 0)))))

(def function text/last-position (text)
  (bind ((elements (elements-of text)))
    (etypecase elements
      (null nil)
      (computed-ll (bind ((last-element (last-element elements)))
                     (text/make-position :element last-element :index (text/element-length (value-of last-element)) :distance nil)))
      (sequence (bind ((last-element (last-elt elements)))
                  (text/make-position :element (1- (length elements)) :index (text/element-length last-element) :distance nil))))))

(def function text/first-position? (text position)
  (not (text/previous-position text position)))

(def function text/last-position? (text position)
  (not (text/next-position text position)))

(def function text/previous-raw-position (text position)
  (bind ((element (text/position-element position))
         (index (text/position-index position))
         (distance (awhen (text/position-distance position) (1- it))))
    (etypecase element
      (integer
       (if (zerop index)
           (when (not (zerop element))
             (text/make-position :element (1- element) :index (text/element-length (elt (elements-of text) (1- element))) :distance distance))
           (text/make-position :element element :index (1- index) :distance distance)))
      (computed-ll
       (if (zerop index)
           (awhen (previous-element-of element)
             (text/make-position :element it :index (text/element-length (value-of it)) :distance distance))
           (text/make-position :element element :index (1- index) :distance distance))))))

(def function text/next-raw-position (text position)
  (bind ((element (text/position-element position))
         (index (text/position-index position))
         (distance (awhen (text/position-distance position) (1+ it))))
    (etypecase element
      (integer
       (bind ((elements (elements-of text))
              (element-length (text/element-length (elt elements element))))
         (if (< index element-length)
             (text/make-position :element element :index (1+ index) :distance distance)
             (unless (= element (1- (length elements)))
               (text/make-position :element (1+ element) :index 0 :distance distance)))))
      (computed-ll
       (bind ((element-length (text/element-length (value-of element))))
         (if (< index element-length)
             (text/make-position :element element :index (1+ index) :distance distance)
             (awhen (next-element-of element)
               (text/make-position :element it :index 0 :distance distance))))))))

(def function text/sibling-position (text position direction)
  (ecase direction
    (:backward (text/previous-position text position))
    (:forward (text/next-position text position))))

(def function text/normalize-backward (text position)
  (bind ((element (text/position-element position))
         (index (text/position-index position))
         (distance (text/position-distance position)))
    (etypecase element
      (integer
       (bind ((elements (elements-of text)))
         (if (= index 0)
             (if (< 0 element)
                 (text/normalize-backward text (text/make-position :element (1- element) :index (text/element-length (elt elements (1- element))) :distance distance))
                 position)
             position)))
      (computed-ll
       (if (= index 0)
           (awhen (previous-element-of element)
             (text/normalize-backward text (text/make-position :element it :index (text/element-length (value-of it)) :distance distance)))
           position)))))

(def function text/normalize-forward (text position)
  (bind ((element (text/position-element position))
         (index (text/position-index position))
         (distance (text/position-distance position)))
    (etypecase element
      (integer
       (bind ((elements (elements-of text))
              (element-length (text/element-length (elt elements element))))
         (if (= index element-length)
             (if (< element (1- (length elements)))
                 (text/normalize-forward text (text/make-position :element (1+ element) :index 0 :distance distance))
                 position)
             position)))
      (computed-ll
       (bind ((element-length (text/element-length (value-of element))))
         (if (= index element-length)
             (aif (next-element-of element)
                  (text/normalize-forward text (text/make-position :element it :index 0 :distance distance))
                  position)
             position))))))

(def function text/normalize-position (text position)
  (text/normalize-forward text position))

(def function text/previous-position (text position)
  (awhen (text/normalize-backward text position)
    (awhen (text/previous-raw-position text it)
      (text/normalize-position text it))))

(def function text/next-position (text position)
  (awhen (text/normalize-forward text position)
    (awhen (text/next-raw-position text it)
      (text/normalize-position text it))))

(def function text/line-start-position (text start-position)
  "Returns the closest position less than or equal to START-POSITION without having a newline character in between."
  (if (text/after-newline? text start-position)
      start-position
      (iter (for element :initially (text/position-element (text/previous-position text start-position)) :then (text/previous-element text element))
            (for previous-element :previous element)
            (unless element
              (return (text/make-position :element previous-element :index 0 :distance nil)))
            (when (text/newline? (text/element text element))
              (return (text/make-position :element previous-element :index 0 :distance nil))))))

(def function text/line-end-position (text start-position)
  "Returns the closest position greater than or equal to START-POSITION without having a newline character in between."
  (if (text/before-newline? text start-position)
      start-position
      (iter (for element :initially (text/position-element (text/next-position text start-position)) :then (text/next-element text element))
            (for previous-element :previous element)
            (unless element
              (return (text/make-position :element previous-element :index (text/element-length (text/element text previous-element)) :distance nil)))
            (when (text/newline? (text/element text element))
              (return (text/make-position :element element :index 0 :distance nil))))))

(def function text/relative-position (text start-position distance)
  (iter (repeat (abs distance))
        (for position :initially start-position :then (if (> distance 0)
                                                          (text/next-position text position)
                                                          (text/previous-position text position)))
        (while position)
        (finally (return position))))

(def function text/previous-character (text position)
  (bind ((normalized-position (text/normalize-backward text position)))
    (when normalized-position
      (bind ((element (text/position-element normalized-position))
             (index (text/position-index normalized-position))
             (string (text/element-content (text/element text element))))
        (if (> index 0)
            (elt string (1- index))
            (etypecase element
              (integer
               (unless (zerop element)
                 (last-elt (content-of (elt (elements-of text) (1- element))))))
              (computed-ll
               (awhen (previous-element-of element)
                 (last-elt (text/element-content (value-of it)))))))))))

(def function text/next-character (text position)
  (bind ((normalized-position (text/normalize-forward text position)))
    (when normalized-position
      (bind ((element (text/position-element normalized-position))
             (index (text/position-index normalized-position))
             (string (text/element-content (text/element text element))))
        (when (< index (length string))
          (elt string index))))))

(def function text/sibling-character (text position direction)
  (ecase direction
    (:backward (text/previous-character text position))
    (:forward (text/next-character text position))))

(def function text/first-element (text)
  (bind ((elements (elements-of text)))
    (if (typep elements 'computed-ll)
        (first-element elements)
        0)))

(def function text/last-element (text)
  (bind ((elements (elements-of text)))
    (if (typep elements 'computed-ll)
        (last-element elements)
        (1- (length elements)))))

(def function text/previous-element (text element)
  (declare (ignore text))
  (etypecase element
    (integer
     (when (> element 0)
       (1- element)))
    (computed-ll (previous-element-of element))))

(def function text/next-element (text element)
  (etypecase element
    (integer
     (when (< element (1- (length (elements-of text))))
       (1+ element)))
    (computed-ll (next-element-of element))))

(def function text/sibling-element (text element direction)
  (ecase direction
    (:backward (text/previous-element text element))
    (:forward (text/next-element text element))))

;; TODO: rename?
(def function text/element (text element)
  (etypecase element
    (integer (elt (elements-of text) element))
    (computed-ll (value-of element))))

(def function text/element-content (element)
  (if (typep element 'text/string)
      (content-of element)
      (list #\NewLine)))

;; TODO: remove and inline?
(def function text/element-length (element)
  (length (text/element-content element)))

;; TODO: what is this?
(def function text/subbox (text start-position end-position)
  (declare (ignore text start-position end-position))
  (not-yet-implemented))

(def function text/empty? (text)
  (bind ((elements (elements-of text)))
    (or (emptyp elements)
        (and (= (length elements) 1)
             (emptyp (content-of (first-elt elements)))))))

(def function text/newline? (element)
  (typep element 'text/newline))

(def function text/before-newline? (text position)
  (bind ((index (text/position-index position))
         (element (text/position-element position))
         (next-position (text/next-position text position) ))
    (or (not next-position)
        (and (= index 0)
             (text/newline? (text/element text element)))
        (and (= index (text/element-length (text/element text element)))
             (text/newline? (text/element text (text/next-element text element)))))))

(def function text/after-newline? (text position)
  (bind ((index (text/position-index position))
         (element (text/position-element position))
         (previous-position (text/previous-position text position)))
    (or (not previous-position)
        (and (= index 0)
             (text/newline? (text/element text (text/previous-element text element))))
        (and (= index 1)
             (text/newline? (text/element text element))))))

;; TODO: optimize
(def function text/length (text &optional (start-position (text/first-position text)) (end-position (text/last-position text)))
  (etypecase (elements-of text)
    (null 0)
    (sequence
     (iter (with end-position = (text/normalize-position text end-position))
           (for position :initially start-position :then (text/next-position text position))
           (while position)
           (until (text/position= position end-position))
           (summing 1)))))

(def function text/substring (text start-position end-position)
  (bind ((start-element (text/element text (text/position-element start-position)))
         (end-element (text/element text (text/position-element end-position))))
    (if (eq start-element end-element)
        (text/text ()
          (typecase start-element
            (text/string (text/string (subseq (content-of start-element) (text/position-index start-position) (text/position-index end-position))
                                      :font (font-of start-element)
                                      :font-color (font-color-of start-element)
                                      :fill-color (fill-color-of start-element)
                                      :line-color (line-color-of start-element)
                                      :padding (padding-of start-element)))
            (t start-element)))
        (text/make-text
         (append (bind ((string (subseq (text/element-content start-element) (text/position-index start-position) (text/element-length start-element))))
                   (unless (zerop (length string))
                     (list (typecase start-element
                             (text/string (text/string string
                                                       :font (font-of start-element)
                                                       :font-color (font-color-of start-element)
                                                       :fill-color (fill-color-of start-element)
                                                       :line-color (line-color-of start-element)
                                                       :padding (padding-of start-element)))
                             (t start-element)))))
                 (iter (for element :initially (text/next-element text (text/position-element start-position)) :then (text/next-element text element))
                       (until (eq element (text/position-element end-position)))
                       (collect (text/element text element)))
                 (bind ((string (subseq (text/element-content end-element) 0 (text/position-index end-position))))
                   (unless (zerop (length string))
                     (list (typecase end-element
                             (text/string (text/string string
                                                       :font (font-of end-element)
                                                       :font-color (font-color-of end-element)
                                                       :fill-color (fill-color-of end-element)
                                                       :line-color (line-color-of end-element)
                                                       :padding (padding-of end-element)))
                             (t end-element))))))))))

(def function text/subseq (text start-character-index &optional (end-character-index (text/length text (text/origin-position text) (text/last-position text))))
  (text/substring text
                  (text/relative-position text (text/origin-position text) start-character-index)
                  (text/relative-position text (text/origin-position text) end-character-index)))

(def function text/find (text start-position test &key (direction :forward))
  (iter (for position :initially start-position :then (text/sibling-position text position direction))
        (while position)
        (for character = (text/sibling-character text position direction))
        (until (and character (funcall test character)))
        (finally (return position))))

(def function text/count (text character &optional (start-position (text/first-position text)) (end-position (text/last-position text)) )
  (iter (for position :initially start-position :then (text/next-position text position))
        (until (text/position= position end-position))
        (when (if (char= character #\NewLine)
                  (and (typep (text/element text (text/position-element position)) 'text/newline)
                       (= 0 (text/position-index position)))
                  (char= character (text/next-character text position)))
          (summing 1))))

(def function text/count-lines (text)
  (etypecase (elements-of text)
    (null 1)
    (sequence (1+ (iter (for element :initially (text/first-element text) :then (text/next-element text element))
                        (while element)
                        (when (typep (text/element text element) 'text/newline)
                          (summing 1)))))))

(def function text/as-string (text)
  (with-output-to-string (stream)
    (iter (for element :in-sequence (elements-of text))
          (typecase element
            (text/newline
             (terpri stream))
            (text/string
             (write-string (content-of element) stream))))))

(def function text/split (text split-character)
  (iter (for start-position :initially (text/first-position text) :then (text/next-position text end-position))
        (while start-position)
        (for end-position = (text/find text start-position (lambda (character) (char= character split-character))))
        (collect (text/substring text start-position (or end-position (text/last-position text))))
        (while end-position)))

(def function text/map-split (text split-character function)
  (iter (for start-position :initially (text/first-position text) :then (text/next-position text end-position))
        (while start-position)
        (for end-position = (text/find text start-position (lambda (character) (char= character split-character))))
        (funcall function start-position (or end-position (text/last-position text)))
        (collect (text/substring text start-position (or end-position (text/last-position text))))
        (while end-position)))

(def function text/concatenate (&rest texts)
  (text/make-text (apply #'concatenate 'vector (mapcar #'elements-of texts))))

(def function text/push (text other)
  (setf (elements-of text) (concatenate 'vector (elements-of text) (elements-of other)))
  text)

(def function text/reference? (reference)
  (pattern-case (reverse reference)
    (((the text/text (text/subseq (the text/text document) ?b ?a)) . ?rest)
     #t)))

(def function text/consolidate (text)
  (text/make-text (iter (with last-string-element = nil)
                        (for element :in-sequence (elements-of text))
                        (if (and last-string-element
                                 (typep element 'text/string)
                                 (eq (font-of element) (font-of last-string-element))
                                 (eq (font-color-of element) (font-color-of last-string-element))
                                 (eq (fill-color-of element) (fill-color-of last-string-element))
                                 (eq (line-color-of element) (line-color-of last-string-element)))
                            (setf (content-of last-string-element) (concatenate 'string (content-of last-string-element) (content-of element)))
                            (collect (if (typep element 'text/string)
                                         (setf last-string-element (text/make-string (copy-seq (content-of element))
                                                                                     :font (font-of element)
                                                                                     :font-color (font-color-of element)
                                                                                     :fill-color (fill-color-of element)
                                                                                     :line-color (line-color-of element)
                                                                                     :padding (padding-of element)))
                                         (progn
                                           (setf last-string-element nil)
                                           element))
                              :result-type vector)))
                  :selection (selection-of text)))

(def function text/replace-style (text &key font font-color fill-color line-color padding)
  (text/make-text (iter (for element :in (elements-of text))
                        (collect (text/string (content-of element)
                                              :font (or font (font-of element))
                                              :font-color (or font-color (font-color-of element))
                                              :fill-color (or fill-color (fill-color-of element))
                                              :line-color (or line-color (line-color-of element))
                                              :padding (or padding (padding-of element)))))))

;; TODO: move and rename
(def function make-command-help-text (command)
  (bind ((gesture (gesture-of command))
         (modifier-text (gesture/describe-modifiers gesture))
         (gesture-text (gesture/describe-key gesture)))
    (list
     (text/string (or (domain-of command) "Unspecified") :font *font/default* :font-color *color/solarized/red*)
     (text/string " " :font *font/default* :font-color *color/black*)
     (text/string (string+ modifier-text gesture-text) :font *font/ubuntu/monospace/regular/18* :font-color *color/solarized/blue*)
     (text/string " " :font *font/default* :font-color *color/black*)
     (text/string (or (description-of command) "No description") :font *font/default* :font-color *color/black*))))

(def function text/read-replace-selection-operation (text key &optional modifier)
  (bind ((new-position
          (pattern-case (selection-of text)
            (((the text/text (text/subseq (the text/text document) ?character-index ?character-index)))
             (bind ((character-index ?character-index)
                    (origin-position (text/origin-position text))
                    (old-position (text/relative-position text origin-position character-index))
                    (line-start-position (text/line-start-position text old-position))
                    (line-end-position (text/line-end-position text old-position))
                    (line-character-index (text/length text line-start-position old-position)))
               (ecase key
                 (:sdl-key-left
                  (if (eq modifier :control)
                      (or (awhen (text/previous-character text old-position)
                            (if (alphanumericp it)
                                (text/find text old-position (complement #'alphanumericp) :direction :backward)
                                (awhen (text/find text old-position #'alphanumericp :direction :backward)
                                  (text/find text it (complement #'alphanumericp) :direction :backward))))
                          (text/first-position text))
                      (text/previous-position text old-position)))
                 (:sdl-key-right
                  (if (eq modifier :control)
                      (or (awhen (text/next-character text old-position)
                            (if (alphanumericp it)
                                (text/find text old-position (complement #'alphanumericp) :direction :forward)
                                (awhen (text/find text old-position #'alphanumericp :direction :forward)
                                  (text/find text it (complement #'alphanumericp) :direction :forward))))
                          (text/last-position text))
                      (text/next-position text old-position)))
                 (:sdl-key-up
                  (awhen (text/previous-position text line-start-position)
                    (bind ((previous-line-start-position (text/line-start-position text it))
                           (previous-line-length (1- (text/length text previous-line-start-position line-start-position))))
                      (text/relative-position text line-start-position (1- (min 0 (- line-character-index previous-line-length)))))))
                 (:sdl-key-down
                  (awhen (text/next-position text line-end-position)
                    (bind ((next-line-end-position (text/line-end-position text it))
                           (next-line-length (1- (text/length text line-end-position next-line-end-position))))
                      (text/relative-position text line-end-position (1+ (min line-character-index next-line-length))))))
                 (:sdl-key-home
                  (if (eq modifier :control)
                      (text/first-position text)
                      line-start-position))
                 (:sdl-key-end
                  (if (eq modifier :control)
                      (text/last-position text)
                      line-end-position))
                 #+nil
                 (:sdl-key-pageup)
                 #+nil
                 (:sdl-key-pagedown))))
            (?a
             (case key
               (:sdl-key-home
                (when (eq modifier :control)
                  (text/first-position text)))
               (:sdl-key-end
                (when (eq modifier :control)
                  (text/last-position text))))))))
    (when new-position
      ;; KLUDGE:
      #+nil
      (when (and (and (eq modifier :control)
                      (member key '(:sdl-key-home :sdl-key-end)))
                 (typep (text/position-element new-position) 'computed-ll))
        (setf (elements-of text) (text/position-element new-position)))
      (bind ((new-character-index (iter (with origin-position = (text/origin-position text))
                                        (for backward-position :initially origin-position :then (when backward-position (text/previous-position text backward-position)))
                                        (for forward-position :initially origin-position :then (when forward-position (text/next-position text forward-position)))
                                        (while (or backward-position forward-position))
                                        (when (and backward-position (text/position= backward-position new-position))
                                          (return (- distance)))
                                        (when (and forward-position (text/position= forward-position new-position))
                                          (return distance))
                                        (summing 1 :into distance))))
        (check-type new-character-index integer)
        (make-operation/replace-selection text `((the text/text (text/subseq (the text/text document) ,new-character-index ,new-character-index))))))))

(def function text/read-operation (text gesture)
  (or (gesture-case gesture
        ((gesture/keyboard/key-press :sdl-key-left)
         :domain "Text" :description "Moves the selection one character to the left"
         :operation (text/read-replace-selection-operation text :sdl-key-left))
        ((gesture/keyboard/key-press :sdl-key-right)
         :domain "Text" :description "Moves the selection one character to the right"
         :operation (text/read-replace-selection-operation text :sdl-key-right))
        ((gesture/keyboard/key-press :sdl-key-left :control)
         :domain "Text" :description "Moves the selection one word to the left"
         :operation (text/read-replace-selection-operation text :sdl-key-left :control))
        ((gesture/keyboard/key-press :sdl-key-right :control)
         :domain "Text" :description "Moves the selection one word to the right"
         :operation (text/read-replace-selection-operation text :sdl-key-right :control))
        ((gesture/keyboard/key-press :sdl-key-up)
         :domain "Text" :description "Moves the selection one line up"
         :operation (text/read-replace-selection-operation text :sdl-key-up))
        ((gesture/keyboard/key-press :sdl-key-down)
         :domain "Text" :description "Moves the selection one line down"
         :operation (text/read-replace-selection-operation text :sdl-key-down))
        #+nil
        ((gesture/keyboard/key-press :sdl-key-pageup)
         :domain "Text" :description "Moves the selection one page up"
         :operation (text/read-replace-selection-operation text :sdl-key-pageup))
        #+nil
        ((gesture/keyboard/key-press :sdl-key-pagedown)
         :domain "Text" :description "Moves the selection one page down"
         :operation (text/read-replace-selection-operation text :sdl-key-pagedown))
        ((gesture/keyboard/key-press :sdl-key-home)
         :domain "Text" :description "Moves the selection to the beginning of the line"
         :operation (text/read-replace-selection-operation text :sdl-key-home))
        ((gesture/keyboard/key-press :sdl-key-end)
         :domain "Text" :description "Moves the selection to the end of the line"
         :operation (text/read-replace-selection-operation text :sdl-key-end))
        ((gesture/keyboard/key-press :sdl-key-home :control)
         :domain "Text" :description "Moves the selection to the beginning of the first line"
         :operation (text/read-replace-selection-operation text :sdl-key-home :control))
        ((gesture/keyboard/key-press :sdl-key-end :control)
         :domain "Text" :description "Moves the selection to the end of the last line"
         :operation (text/read-replace-selection-operation text :sdl-key-end :control))
        ((gesture/keyboard/key-press :sdl-key-delete)
         :domain "Text" :description "Deletes the character following the selection"
         :operation (pattern-case (selection-of text)
                      (((the text/text (text/subseq (the text/text document) ?b ?b)))
                       (when (< ?b (text/length text))
                         (make-operation/text/replace-range text `((the text/text (text/subseq (the text/text document) ,?b ,(1+ ?b)))) "")))))
        ((gesture/keyboard/key-press :sdl-key-delete :control)
         :domain "Text" :description "Deletes the word following the selection"
         :operation (pattern-case (selection-of text)
                      (((the text/text (text/subseq (the text/text document) ?b ?b)))
                       (bind ((start-position (text/relative-position text (text/origin-position text) ?b))
                              (end-position (or (awhen (text/find text start-position (lambda (c) (alphanumericp c)))
                                                  (text/find text it (lambda (c) (not (alphanumericp c)))))
                                                (text/last-position text))))
                         (when end-position
                           (make-operation/text/replace-range text `((the text/text (text/subseq (the text/text document) ,?b ,(+ ?b (text/length text start-position end-position))))) ""))))))
        ((gesture/keyboard/key-press :sdl-key-backspace)
         :domain "Text" :description "Deletes the character preceding the selection"
         :operation (pattern-case (selection-of text)
                      (((the text/text (text/subseq (the text/text document) ?b ?b)))
                       (make-operation/text/replace-range text `((the text/text (text/subseq (the text/text document) ,(1- ?b) ,?b))) ""))))
        ((gesture/keyboard/key-press :sdl-key-backspace :control)
         :domain "Text" :description "Deletes the word preceding the selection"
         :operation (pattern-case (selection-of text)
                      (((the text/text (text/subseq (the text/text document) ?b ?b)))
                       (bind ((end-position (text/relative-position text (text/origin-position text) ?b))
                              (start-position (or (awhen (text/find text end-position (lambda (c) (alphanumericp c)) :direction :backward)
                                                    (text/find text it (lambda (c) (not (alphanumericp c))) :direction :backward))
                                                  (text/first-position text))))
                         (when start-position
                           (make-operation/text/replace-range text `((the text/text (text/subseq (the text/text document) ,(- ?b (text/length text start-position end-position)) ,?b))) ""))))))
        ((gesture/keyboard/key-press :sdl-key-i :control)
         :domain "Text" :description "Describes the character at the selection"
         :operation (make-operation/describe (selection-of text))))
      ;; TODO: move into gesture-case
      (cond ((and (typep gesture 'gesture/keyboard/key-press)
                  (null (set-difference (modifiers-of gesture) '(:shift)))
                  (character-of gesture)
                  (or (graphic-char-p (character-of gesture))
                      (whitespace? (character-of gesture))))
             (bind ((character (character-of gesture))
                    (replacement (cond ((eq character #\Return)
                                        (string #\NewLine))
                                       (t (string character)))))
               (pattern-case (selection-of text)
                 (((the text/text (text/subseq (the text/text document) ?b ?b)) . ?rest)
                  (make-command gesture
                                (make-operation/text/replace-range text (selection-of text) replacement)
                                :domain "Text"
                                :description "Inserts a new character at the selection"))))))))

(def method run-operation ((operation operation/text/replace-range))
  (bind ((document (document-of operation))
         (selection (selection-of operation))
         (replacement (replacement-of operation)))
    (pattern-case (reverse selection)
      (((the text/text (text/subseq (the text/text document) ?start-character-index ?end-character-index)) . ?rest)
       (bind ((text-reference (reference/flatten (reverse ?rest)))
              (text (eval-reference document text-reference))
              (origin-position (text/origin-position text))
              (start-position (text/relative-position text origin-position ?start-character-index))
              (end-position (text/relative-position text origin-position ?end-character-index))
              (start-element (text/element text (text/position-element start-position)))
              (start-content (content-of start-element))
              (new-character-index (if (>= ?start-character-index 0)
                                       (+ ?start-character-index (length replacement))
                                       ?end-character-index)))
         (setf (content-of start-element)
               (concatenate (form-type start-content)
                            (subseq start-content 0 (text/position-index start-position))
                            replacement
                            (subseq start-content (+ (text/position-index start-position) (text/length text start-position end-position)))))
         (set-selection document (append (reverse ?rest) `((the text/text (text/subseq (the text/text document) ,new-character-index ,new-character-index))))))))))
