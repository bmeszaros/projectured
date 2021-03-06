;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(in-package :projectured)

;;;;;;
;;; Projection

(def projection json/insertion->tree/leaf ()
  ())

(def projection json/null->tree/leaf ()
  ())

(def projection json/boolean->tree/leaf ()
  ())

(def projection json/number->tree/leaf ()
  ())

(def projection json/string->tree/leaf ()
  ())

(def projection json/array->tree/node ()
  ())

(def projection json/object-entry->tree/node ()
  ())

(def projection json/object->tree/node ()
  ())

;;;;;;
;;; Construction

(def function make-projection/json/insertion->tree/leaf ()
  (make-projection 'json/insertion->tree/leaf))

(def function make-projection/json/null->tree/leaf ()
  (make-projection 'json/null->tree/leaf))

(def function make-projection/json/boolean->tree/leaf ()
  (make-projection 'json/boolean->tree/leaf))

(def function make-projection/json/number->tree/leaf ()
  (make-projection 'json/number->tree/leaf))

(def function make-projection/json/string->tree/leaf ()
  (make-projection 'json/string->tree/leaf))

(def function make-projection/json/array->tree/node ()
  (make-projection 'json/array->tree/node))

(def function make-projection/json/object-entry->tree/node ()
  (make-projection 'json/object-entry->tree/node))

(def function make-projection/json/object->tree/node ()
  (make-projection 'json/object->tree/node))

;;;;;;
;;; Construction

(def macro json/insertion->tree/leaf ()
  '(make-projection/json/insertion->tree/leaf))

(def macro json/null->tree/leaf ()
  '(make-projection/json/null->tree/leaf))

(def macro json/boolean->tree/leaf ()
  '(make-projection/json/boolean->tree/leaf))

(def macro json/number->tree/leaf ()
  '(make-projection/json/number->tree/leaf))

(def macro json/string->tree/leaf ()
  `(make-projection/json/string->tree/leaf))

(def macro json/array->tree/node ()
  `(make-projection/json/array->tree/node))

(def macro json/object-entry->tree/node ()
  '(make-projection/json/object-entry->tree/node))

(def macro json/object->tree/node ()
  '(make-projection/json/object->tree/node))

;;;;;;
;;; Forward mapper

(def function forward-mapper/json/insertion->tree/leaf (printer-iomap reference)
  (bind ((projection (projection-of printer-iomap))
         (recursion (recursion-of printer-iomap)))
    (pattern-case reference
      (((the string (value-of (the json/insertion document)))
        (the string (subseq (the string document) 0 0)))
       `((the text/text (content-of (the tree/leaf document)))
         (the text/text (text/subseq (the text/text document) 0 0))))
      (((the tree/leaf (printer-output (the json/insertion document) ?projection ?recursion)) . ?rest)
       (when (and (eq projection ?projection) (eq recursion ?recursion))
         ?rest)))))

(def function forward-mapper/json/null->tree/leaf (printer-iomap reference)
  (bind ((projection (projection-of printer-iomap))
         (recursion (recursion-of printer-iomap)))
    (pattern-case reference
      (((the json/null document))
       '((the tree/leaf document)))
      (((the string (value-of (the json/null document)))
        (the string (subseq (the string document) ?start-index ?end-index)))
       `((the text/text (content-of (the tree/leaf document)))
         (the text/text (text/subseq (the text/text document) ,?start-index ,?end-index))))
      (((the tree/leaf (printer-output (the json/null document) ?projection ?recursion)) . ?rest)
       (when (and (eq projection ?projection) (eq recursion ?recursion))
         ?rest)))))

(def function forward-mapper/json/boolean->tree/leaf (printer-iomap reference)
  (bind ((projection (projection-of printer-iomap))
         (recursion (recursion-of printer-iomap)))
    (pattern-case reference
      (((the json/boolean document))
       '((the tree/leaf document)))
      (((the string ((?or false-value-of true-value-of) (the json/boolean document)))
        (the string (subseq (the string document) ?start-index ?end-index)))
       `((the text/text (content-of (the tree/leaf document)))
         (the text/text (text/subseq (the text/text document) ,?start-index ,?end-index))))
      (((the tree/leaf (printer-output (the json/boolean document) ?projection ?recursion)) . ?rest)
       (when (and (eq projection ?projection) (eq recursion ?recursion))
         ?rest)))))

(def function forward-mapper/json/number->tree/leaf (printer-iomap reference)
  (bind ((projection (projection-of printer-iomap))
         (recursion (recursion-of printer-iomap)))
    (pattern-case reference
      (((the json/number document))
       '((the tree/leaf document)))
      (((the number (value-of (the json/number document)))
        (the string (write-to-string (the number document)))
        (the string (subseq (the string document) ?start-index ?end-index)))
       `((the text/text (content-of (the tree/leaf document)))
         (the text/text (text/subseq (the text/text document) ,?start-index ,?end-index))))
      (((the tree/leaf (printer-output (the json/number document) ?projection ?recursion)) . ?rest)
       (when (and (eq projection ?projection) (eq recursion ?recursion))
         ?rest)))))

(def function forward-mapper/json/string->tree/leaf (printer-iomap reference)
  (bind ((projection (projection-of printer-iomap))
         (recursion (recursion-of printer-iomap)))
    (pattern-case reference
      (((the json/string document))
       '((the tree/leaf document)))
      (((the string (value-of (the json/string document)))
        (the string (subseq (the string document) ?start-index ?end-index)))
       `((the text/text (content-of (the tree/leaf document)))
         (the text/text (text/subseq (the text/text document) ,?start-index ,?end-index))))
      (((the tree/leaf (printer-output (the json/string document) ?projection ?recursion)) . ?rest)
       (when (and (eq projection ?projection) (eq recursion ?recursion))
         ?rest)))))

(def function forward-mapper/json/array->tree/node (printer-iomap reference)
  (bind ((projection (projection-of printer-iomap))
         (recursion (recursion-of printer-iomap)))
    (pattern-case reference
      (((the json/array document))
       '((the tree/node document)))
      (((the sequence (elements-of (the json/array document)))
        (the ?element-type (elt (the sequence document) ?element-index))
        . ?rest)
       (bind ((element-iomap (elt (child-iomaps-of printer-iomap) ?element-index))
              (element-output (output-of element-iomap)))
         (values `((the sequence (children-of (the tree/node document)))
                   (the ,(form-type element-output) (elt (the sequence document) ,?element-index)))
                 ?rest
                 element-iomap)))
      (((the tree/node (printer-output (the json/array document) ?projection ?recursion)) . ?rest)
       (when (and (eq projection ?projection) (eq recursion ?recursion))
         ?rest)))))

(def function forward-mapper/json/object-entry->tree/node (printer-iomap reference)
  (bind ((projection (projection-of printer-iomap))
         (recursion (recursion-of printer-iomap)))
    (pattern-case reference
      (((the json/object-entry document))
       '((the tree/node document)))
      (((the string (key-of (the json/object-entry document)))
        (the string document))
       '((the sequence (children-of (the tree/node document)))
         (the tree/leaf (elt (the sequence document) 0))
         (the tree/leaf document)))
      (((the string (key-of (the json/object-entry document)))
        (the string (subseq (the string document) ?start-index ?end-index)))
       `((the sequence (children-of (the tree/node document)))
         (the tree/leaf (elt (the sequence document) 0))
         (the text/text (content-of (the tree/leaf document)))
         (the text/text (text/subseq (the text/text document) ,?start-index ,?end-index))))
      (((the ?value-type (value-of (the json/object-entry document)))
        . ?rest)
       (values `((the sequence (children-of (the tree/node document)))
                 (the ,(form-type (output-of (first-elt (child-iomaps-of printer-iomap)))) (elt (the sequence document) 1)))
               ?rest
               (first-elt (child-iomaps-of printer-iomap))))
      (((the tree/node (printer-output (the json/object-entry document) ?projection ?recursion)) . ?rest)
       (when (and (eq projection ?projection) (eq recursion ?recursion))
         ?rest)))))

(def function forward-mapper/json/object->tree/node (printer-iomap reference)
  (bind ((projection (projection-of printer-iomap))
         (recursion (recursion-of printer-iomap)))
    (pattern-case reference
      (((the json/object document))
       '((the tree/node document)))
      (((the sequence (entries-of (the json/object document)))
        (the ?entry-type (elt (the sequence document) ?entry-index))
        . ?rest)
       (bind ((entry-iomap (elt (child-iomaps-of printer-iomap) ?entry-index)))
         (values `((the sequence (children-of (the tree/node document)))
                   (the ,(form-type (output-of entry-iomap)) (elt (the sequence document) ,?entry-index)))
                 ?rest
                 entry-iomap)))
      (((the tree/node (printer-output (the json/object document) ?projection ?recursion)) . ?rest)
       (when (and (eq projection ?projection) (eq recursion ?recursion))
         ?rest)))))

;;;;;;
;;; Backward mapper

(def function backward-mapper/json/insertion->tree/leaf (printer-iomap reference)
  (bind ((projection (projection-of printer-iomap))
         (recursion (recursion-of printer-iomap)))
    (pattern-case reference
      (((the text/text (content-of (the tree/leaf document)))
        (the text/text (text/subseq (the text/text document) 0 0)))
       `((the string (value-of (the json/insertion document)))
         (the string (subseq (the string document) 0 0))))
      (?a
       (append `((the tree/leaf (printer-output (the json/insertion document) ,projection ,recursion))) reference)))))

(def function backward-mapper/json/null->tree/leaf (printer-iomap reference)
  (bind ((projection (projection-of printer-iomap))
         (recursion (recursion-of printer-iomap)))
    (pattern-case reference
      (((the tree/leaf document))
       '((the json/null document)))
      (((the text/text (content-of (the tree/leaf document)))
        (the text/text (text/subseq (the text/text document) ?start-index ?end-index)))
       `((the string (value-of (the json/null document)))
         (the string (subseq (the string document) ,?start-index ,?end-index))))
      (?a
       (append `((the tree/leaf (printer-output (the json/null document) ,projection ,recursion))) reference)))))

(def function backward-mapper/json/boolean->tree/leaf (printer-iomap reference)
  (bind ((printer-input (input-of printer-iomap))
         (projection (projection-of printer-iomap))
         (recursion (recursion-of printer-iomap)))
    (pattern-case reference
      (((the tree/leaf document))
       '((the json/boolean document)))
      (((the text/text (content-of (the tree/leaf document)))
        (the text/text (text/subseq (the text/text document) ?start-index ?end-index)))
       `((the string (,(if (value-p printer-input) 'true-value-of 'false-value-of) (the json/boolean document)))
         (the string (subseq (the string document) ,?start-index ,?end-index))))
      (?a
       (append `((the tree/leaf (printer-output (the json/boolean document) ,projection ,recursion))) reference)))))

(def function backward-mapper/json/number->tree/leaf (printer-iomap reference)
  (bind ((printer-input (input-of printer-iomap))
         (projection (projection-of printer-iomap))
         (recursion (recursion-of printer-iomap)))
    (pattern-case reference
      (((the tree/leaf document))
       '((the json/number document)))
      (((the text/text (content-of (the tree/leaf document)))
        (the text/text (text/subseq (the text/text document) ?start-index ?end-index)))
       (if (not (value-of printer-input))
           (append `((the tree/leaf (printer-output (the json/number document) ,projection ,recursion))) reference)
           `((the number (value-of (the json/number document)))
             (the string (write-to-string (the number document)))
             (the string (subseq (the string document) ,?start-index ,?end-index)))))
      (?a
       (append `((the tree/leaf (printer-output (the json/number document) ,projection ,recursion))) reference)))))

(def function backward-mapper/json/string->tree/leaf (printer-iomap reference)
  (bind ((printer-input (input-of printer-iomap))
         (projection (projection-of printer-iomap))
         (recursion (recursion-of printer-iomap)))
    (pattern-case reference
      (((the tree/leaf document))
       '((the json/string document)))
      (((the text/text (content-of (the tree/leaf document)))
        (the text/text (text/subseq (the text/text document) ?start-index ?end-index)))
       (if (string= (value-of printer-input) "")
           (append `((the tree/leaf (printer-output (the json/string document) ,projection ,recursion))) reference)
           `((the string (value-of (the json/string document)))
             (the string (subseq (the string document) ,?start-index ,?end-index)))))
      (?a
       (append `((the tree/leaf (printer-output (the json/string document) ,projection ,recursion))) reference)))))

(def function backward-mapper/json/array->tree/node (printer-iomap reference)
  (bind ((printer-input (input-of printer-iomap))
         (projection (projection-of printer-iomap))
         (recursion (recursion-of printer-iomap)))
    (pattern-case reference
      (((the tree/node document))
       '((the json/array document)))
      (((the sequence (children-of (the tree/node document)))
        (the ?child-type (elt (the sequence document) ?child-index))
        . ?rest)
       (bind ((child (elt (elements-of printer-input) ?child-index))
              (child-iomap (elt (child-iomaps-of printer-iomap) ?child-index)))
         (values `((the sequence (elements-of (the json/array document)))
                   (the ,(form-type child) (elt (the sequence document) ,?child-index)))
                 ?rest
                 child-iomap)))
      (((the sequence (children-of (the tree/node document)))
        (the sequence (subseq (the sequence document) ?start-index ?end-index))
        . ?rest)
       (if (= ?start-index (1- ?end-index))
           (bind ((child-iomap (elt (child-iomaps-of printer-iomap) ?start-index)))
             (values `((the sequence (elements-of (the json/array document)))
                       (the sequence (subseq (the sequence document) ,?start-index ,?end-index)))
                     ?rest
                     child-iomap))
           (append `((the tree/node (printer-output (the json/array document) ,projection ,recursion))) reference)))
      (?a
       (append `((the tree/node (printer-output (the json/array document) ,projection ,recursion))) reference)))))

(def function backward-mapper/json/object-entry->tree/node (printer-iomap reference)
  (bind ((printer-input (input-of printer-iomap))
         (projection (projection-of printer-iomap))
         (recursion (recursion-of printer-iomap)))
    (pattern-case reference
      (((the tree/node document))
       '((the json/object-entry document)))
      (((the sequence (children-of (the tree/node document)))
        (the tree/leaf (elt (the sequence document) 0))
        (the tree/leaf document))
       '((the string (key-of (the json/object-entry document)))
         (the string document)))
      (((the sequence (children-of (the tree/node document)))
        (the tree/leaf (elt (the sequence document) 0))
        (the text/text (content-of (the tree/leaf document)))
        (the text/text (text/subseq (the text/text document) ?start-index ?end-index)))
       (if (string= (key-of printer-input) "")
           (append `((the tree/node (printer-output (the json/object-entry document) ,projection ,recursion))) reference)
           `((the string (key-of (the json/object-entry document)))
             (the string (subseq (the string document) ,?start-index ,?end-index)))))
      (((the sequence (children-of (the tree/node document)))
        (the ?child-type (elt (the sequence document) 1))
        . ?rest)
       (values `((the ,(form-type (value-of printer-input)) (value-of (the json/object-entry document))))
               ?rest
               (elt (child-iomaps-of printer-iomap) 0)))
      (?a
       (append `((the tree/node (printer-output (the json/object-entry document) ,projection ,recursion))) reference)))))

(def function backward-mapper/json/object->tree/node (printer-iomap reference)
  (bind ((printer-input (input-of printer-iomap))
         (projection (projection-of printer-iomap))
         (recursion (recursion-of printer-iomap)))
    (pattern-case reference
      (((the tree/node document))
       '((the json/object document)))
      (((the sequence (children-of (the tree/node document)))
        (the ?child-type (elt (the sequence document) ?child-index))
        . ?rest)
       (bind ((entry (elt (entries-of printer-input) ?child-index))
              (entry-iomap (elt (child-iomaps-of printer-iomap) ?child-index)))
         (values `((the sequence (entries-of (the json/object document)))
                   (the ,(form-type entry) (elt (the sequence document) ,?child-index)))
                 ?rest
                 entry-iomap)))
      (((the sequence (children-of (the tree/node document)))
        (the sequence (subseq (the sequence document) ?start-index ?end-index))
        . ?rest)
       (if (= ?start-index (1- ?end-index))
           (bind ((entry-iomap (elt (child-iomaps-of printer-iomap) ?start-index)))
             (values `((the sequence (entries-of (the json/object document)))
                       (the sequence (subseq (the sequence document) ,?start-index ,?end-index)))
                     ?rest
                     entry-iomap))
           (append `((the tree/node (printer-output (the json/object document) ,projection ,recursion))) reference)))
      (?a
       (append `((the tree/node (printer-output (the json/object document) ,projection ,recursion))) reference)))))

;;;;;;
;;; Printer

(def printer json/insertion->tree/leaf (projection recursion input input-reference)
  (bind ((output-selection (as (print-selection (make-iomap/object projection recursion input input-reference nil) (selection-of input) 'forward-mapper/json/insertion->tree/leaf)))
         (output (as (tree/leaf (:selection output-selection)
                       (text/text (:selection (as (nthcdr 1 (va output-selection))))
                         (text/string (value-of input) :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/blue*))))))
    (make-iomap/object projection recursion input input-reference output)))

(def printer json/null->tree/leaf (projection recursion input input-reference)
  (bind ((output-selection (as (print-selection (make-iomap/object projection recursion input input-reference nil) (selection-of input) 'forward-mapper/json/null->tree/leaf)))
         (output (as (tree/leaf (:selection output-selection)
                       (text/text (:selection (as (nthcdr 1 (va output-selection))))
                         (text/string (value-of input) :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/blue*))))))
    (make-iomap/object projection recursion input input-reference output)))

(def printer json/boolean->tree/leaf (projection recursion input input-reference)
  (bind ((output-selection (as (print-selection (make-iomap/object projection recursion input input-reference nil) (selection-of input) 'forward-mapper/json/boolean->tree/leaf)))
         (output (as (tree/leaf (:selection output-selection)
                       (text/text (:selection (as (nthcdr 1 (va output-selection))))
                         (text/string (if (value-p input) (true-value-of input) (false-value-of input)) :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/blue*))))))
    (make-iomap/object projection recursion input input-reference output)))

(def printer json/number->tree/leaf (projection recursion input input-reference)
  (bind ((output-selection (as (print-selection (make-iomap/object projection recursion input input-reference nil) (selection-of input) 'forward-mapper/json/number->tree/leaf)))
         (output (as (tree/leaf (:selection output-selection)
                       (text/make-default-text (aif (value-of input) (write-to-string it) "") "enter json number" :selection (as (nthcdr 1 (va output-selection))) :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/magenta*)))))
    (make-iomap/object projection recursion input input-reference output)))

(def printer json/string->tree/leaf (projection recursion input input-reference)
  (bind ((output-selection (as (print-selection (make-iomap/object projection recursion input input-reference nil) (selection-of input) 'forward-mapper/json/string->tree/leaf)))
         (output (as (tree/leaf (:opening-delimiter (text/text () (text/string "\"" :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/gray*))
                                 :closing-delimiter (text/text () (text/string "\"" :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/gray*))
                                 :selection output-selection)
                       (text/make-default-text (value-of input) "enter json string" :selection (as (nthcdr 1 (va output-selection))) :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/green*)))))
    (make-iomap/object projection recursion input input-reference output)))

(def printer json/array->tree/node (projection recursion input input-reference)
  (bind ((deep-array (find-if-not (of-type '(or json/insertion json/null json/boolean json/number json/string)) (elements-of input)))
         (element-iomaps (as (iter (for element-index :from 0)
                                   (for element :in-sequence (elements-of input))
                                   (for element-iomap = (recurse-printer recursion element
                                                                         `((elt (the sequence document) ,element-index)
                                                                           (the sequence (elements-of (the json/array document)))
                                                                           ,@(typed-reference (form-type input) input-reference))))
                                   (when (and deep-array (not (first-iteration-p)))
                                     (setf (indentation-of (output-of element-iomap)) 1))
                                   (collect element-iomap))))
         (output-selection (as (print-selection (make-iomap/compound projection recursion input input-reference nil element-iomaps) (selection-of input) 'forward-mapper/json/array->tree/node)))
         (output (as (make-tree/node (as (mapcar 'output-of (va element-iomaps)))
                                     :opening-delimiter (text/text () (text/string "[" :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/gray*))
                                     :closing-delimiter (text/text () (text/string "]" :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/gray*))
                                     :separator (text/text () (text/string (if deep-array "," ", ") :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/gray*))
                                     :selection output-selection))))
    (make-iomap/compound projection recursion input input-reference output element-iomaps)))

(def printer json/object-entry->tree/node (projection recursion input input-reference)
  (bind ((value-iomap (as (recurse-printer recursion (value-of input)
                                           `((value-of (the json/object-entry document))
                                             ,@(typed-reference (form-type input) input-reference)))))
         (output-selection (as (print-selection (make-iomap/compound projection recursion input input-reference nil (as (list (va value-iomap)))) (selection-of input) 'forward-mapper/json/object-entry->tree/node)))
         (output (as (tree/node (:separator (text/text () (text/string " : " :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/gray*))
                                 :selection output-selection)
                       (tree/leaf (:opening-delimiter (text/text () (text/string "\"" :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/gray*))
                                   :closing-delimiter (text/text () (text/string "\"" :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/gray*))
                                   :selection (as (nthcdr 2 (va output-selection))))
                         (text/make-default-text (key-of input) "enter key" :selection (as (nthcdr 3 (va output-selection))) :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/red*))
                       (output-of (va value-iomap))))))
    (make-iomap/compound projection recursion input input-reference output (as (list (va value-iomap))))))

(def printer json/object->tree/node (projection recursion input input-reference)
  (bind ((entry-iomaps (as (iter (for index :from 0)
                                 (for entry :in-sequence (entries-of input))
                                 (for entry-iomap = (recurse-printer recursion entry
                                                                     `((elt (the sequence document) ,index)
                                                                       (the sequence (entries-of (the json/object document)))
                                                                       ,@(typed-reference (form-type input) input-reference))))
                                 (unless (first-iteration-p)
                                   (setf (indentation-of (output-of entry-iomap)) 1))
                                 (collect entry-iomap))))
         (output-selection (as (print-selection (make-iomap/compound projection recursion input input-reference nil entry-iomaps) (selection-of input) 'forward-mapper/json/object->tree/node)))
         (output (as (make-tree/node (as (mapcar 'output-of (va entry-iomaps)))
                                     :opening-delimiter (text/text () (text/string "{" :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/gray*))
                                     :closing-delimiter (text/text () (text/string "}" :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/gray*))
                                     :separator (text/text () (text/string "," :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/gray*))
                                     :selection output-selection))))
    (make-iomap/compound projection recursion input input-reference output entry-iomaps)))

;;;;;;
;;; Reader

(def function json/read-command (printer-iomap gesture)
  (bind ((printer-input (input-of printer-iomap)))
    (merge-commands (gesture-case gesture
                      ((gesture/keyboard/key-press #\n)
                       :domain "JSON" :description "Replaces the selected element with null"
                       :operation (make-operation/replace-target printer-input nil (json/null (:selection '((the string (value-of (the json/null document)))
                                                                                                            (the string (subseq (the string document) 0 0)))))))
                      ((gesture/keyboard/key-press #\f)
                       :domain "JSON" :description "Replaces the selected element with false"
                       :operation (make-operation/replace-target printer-input nil (json/boolean (:selection '((the string (false-value-of (the json/boolean document)))
                                                                                                               (the string (subseq (the string document) 0 0))))
                                                                                     #f)))
                      ((gesture/keyboard/key-press #\t)
                       :domain "JSON" :description "Replaces the selected element with true"
                       :operation (make-operation/replace-target printer-input nil (json/boolean (:selection '((the string (true-value-of (the json/boolean document)))
                                                                                                               (the string (subseq (the string document) 0 0))))
                                                                                     #t)))
                      ((gesture/keyboard/key-press #\" :shift) ;; TODO: modifier
                       :domain "JSON" :description "Replaces the selected element with an empty string"
                       :operation (make-operation/replace-target printer-input nil (json/string (:selection '((the string (value-of (the json/string document)))
                                                                                                              (the string (subseq (the string document) 0 0))))
                                                                                     "")))
                      ((gesture/keyboard/key-press #\[)
                       :domain "JSON" :description "Replaces the selected element with an empty array"
                       :operation (make-operation/replace-target printer-input nil (json/array (:selection '((the sequence (elements-of (the json/array document)))
                                                                                                             (the json/insertion (elt (the sequence document) 0))
                                                                                                             (the string (value-of (the json/insertion document)))
                                                                                                             (the string (subseq (the string document) 0 0))))
                                                                                     (json/insertion (:selection '((the string (value-of (the json/insertion document)))
                                                                                                                   (the string (subseq (the string document) 0 0))))))))
                      ((gesture/keyboard/key-press #\: :shift)
                       :domain "JSON" :description "Replaces the selected element with a json object entry"
                       :operation (make-operation/replace-target printer-input nil (json/object-entry (:selection '((the string (key-of (the json/object-entry document)))
                                                                                                                    (the string (subseq (the string document) 0 0))))
                                                                                                      ""
                                                                                                      (json/insertion ()))))
                      ((gesture/keyboard/key-press #\{ :shift) ;; TODO: modifier
                       :domain "JSON" :description "Replaces the selected element with an empty object"
                       :operation (make-operation/replace-target printer-input nil (make-json/object (make-document/sequence (list (json/insertion (:selection '((the string (value-of (the json/insertion document)))
                                                                                                                                                                 (the string (subseq (the string document) 0 0))))))
                                                                                                                             :selection '((the json/insertion (elt (the sequence document) 0))
                                                                                                                                          (the string (value-of (the json/insertion document)))
                                                                                                                                          (the string (subseq (the string document) 0 0))))
                                                                                                     :selection '((the sequence (entries-of (the json/object document)))
                                                                                                                  (the json/insertion (elt (the sequence document) 0))
                                                                                                                  (the string (value-of (the json/insertion document)))
                                                                                                                  (the string (subseq (the string document) 0 0)))))))
                    (when (and (typep gesture 'gesture/keyboard/key-press)
                               (character-of gesture)
                               (digit-char-p (character-of gesture)))
                      (make-command gesture
                                    (make-operation/replace-target printer-input nil (json/number (:selection '((the number (value-of (the json/number document)))
                                                                                                                (the string (write-to-string (the number document)))
                                                                                                                (the string (subseq (the string document) 1 1))))
                                                                                       (parse-integer (string (character-of gesture)))))
                                    :domain "JSON"
                                    :description "TODO")))))

(def reader json/insertion->tree/leaf (projection recursion input printer-iomap)
  (declare (ignore projection))
  (merge-commands (command/read-backward recursion input printer-iomap 'backward-mapper/json/insertion->tree/leaf nil)
                  (json/read-command printer-iomap (gesture-of input))
                  (make-command/nothing (gesture-of input))))

(def reader json/null->tree/leaf (projection recursion input printer-iomap)
  (declare (ignore projection))
  (merge-commands (command/read-backward recursion input printer-iomap 'backward-mapper/json/null->tree/leaf nil)
                  (json/read-command printer-iomap (gesture-of input))
                  (make-command/nothing (gesture-of input))))

(def reader json/boolean->tree/leaf (projection recursion input printer-iomap)
  (declare (ignore projection))
  (merge-commands (command/read-backward recursion input printer-iomap 'backward-mapper/json/boolean->tree/leaf nil)
                  (json/read-command printer-iomap (gesture-of input))
                  (make-command/nothing (gesture-of input))))

(def reader json/number->tree/leaf (projection recursion input printer-iomap)
  (declare (ignore projection))
  (bind ((printer-input (input-of printer-iomap))
         (operation-mapper (lambda (operation selection child-selection child-iomap)
                             (declare (ignore child-selection child-iomap))
                             (typecase operation
                               (operation/text/replace-range
                                (pattern-case selection
                                  (((the number (value-of (the json/number document)))
                                    (the string (write-to-string (the number document)))
                                    (the string (subseq (the string document) ?start-index ?end-index)))
                                   (when (every 'digit-char-p (replacement-of operation))
                                     (make-operation/number/replace-range printer-input selection (replacement-of operation))))
                                  (((the tree/leaf (printer-output (the json/number document) ?projection ?recursion)) . ?rest)
                                   (when (every 'digit-char-p (replacement-of operation))
                                     (make-operation/number/replace-range printer-input
                                                                          '((the number (value-of (the json/number document)))
                                                                            (the string (write-to-string (the number document)))
                                                                            (the string (subseq (the string document) 0 0)))
                                                                          (replacement-of operation))))))))))
    (merge-commands (command/read-backward recursion input printer-iomap 'backward-mapper/json/number->tree/leaf operation-mapper)
                    (make-command/nothing (gesture-of input)))))

(def reader json/string->tree/leaf (projection recursion input printer-iomap)
  (declare (ignore projection))
  (bind ((printer-input (input-of printer-iomap))
         (operation-mapper (lambda (operation selection child-selection child-iomap)
                             (declare (ignore child-selection child-iomap))
                             (typecase operation
                               (operation/text/replace-range
                                (pattern-case selection
                                  (((the string (value-of (the json/string document)))
                                    (the string (subseq (the string document) ?start-index ?end-index)))
                                   (make-operation/sequence/replace-range printer-input selection (replacement-of operation)))
                                  (((the tree/leaf (printer-output (the json/string document) ?projection ?recursion)) . ?rest)
                                   (make-operation/sequence/replace-range printer-input
                                                                          '((the string (value-of (the json/string document)))
                                                                            (the string (subseq (the string document) 0 0)))
                                                                          (replacement-of operation)))))))))
    (merge-commands (command/read-backward recursion input printer-iomap 'backward-mapper/json/string->tree/leaf operation-mapper)
                    (make-command/nothing (gesture-of input)))))

(def reader json/array->tree/node (projection recursion input printer-iomap)
  (declare (ignore projection))
  (bind ((printer-input (input-of printer-iomap)))
    (merge-commands (command/read-selection recursion input printer-iomap 'forward-mapper/json/array->tree/node 'backward-mapper/json/array->tree/node)
                    (gesture-case (gesture-of input)
                      ((gesture/keyboard/key-press #\,)
                       :domain "JSON" :description "Starts a JSON object insertion into the elements of the JSON array"
                       :operation (bind ((index (length (elements-of printer-input))))
                                    (make-operation/compound (list (make-operation/sequence/replace-range printer-input
                                                                                                          `((the sequence (elements-of (the json/array document)))
                                                                                                            (the sequence (subseq (the sequence document) ,index ,index)))
                                                                                                          (list (json/insertion ())))
                                                                   (make-operation/replace-selection printer-input `((the sequence (elements-of (the json/array document)))
                                                                                                                     (the json/insertion (elt (the sequence document) ,index))
                                                                                                                     (the string (value-of (the json/insertion document)))
                                                                                                                     (the string (subseq (the string document) 0 0))))))))
                      ((gesture/keyboard/key-press :sdl-key-insert)
                       :domain "JSON" :description "Starts an insertion into the elements of the JSON array"
                       :operation (bind ((elements-length (length (elements-of printer-input))))
                                    (make-operation/compound (list (make-operation/sequence/replace-range printer-input `((the sequence (elements-of (the json/array document)))
                                                                                                                          (the sequence (subseq (the sequence document) ,elements-length ,elements-length)))
                                                                                                          (list (document/insertion)))
                                                                   (make-operation/replace-selection printer-input `((the sequence (elements-of (the json/array document)))
                                                                                                                     (the document/insertion (elt (the sequence document) ,elements-length))
                                                                                                                     (the string (value-of (the document/insertion document)))
                                                                                                                     (the string (subseq (the string document) 0 0))))))))
                      ((gesture/keyboard/key-press #\" :shift) ;; TODO: modifier
                       :domain "JSON" :description "Inserts an empty string"
                       :operation (bind ((index (length (elements-of printer-input))))
                                    (make-operation/compound (list (make-operation/sequence/replace-range printer-input
                                                                                                          `((the sequence (elements-of (the json/array document)))
                                                                                                            (the sequence (subseq (the sequence document) ,index ,index)))
                                                                                                          (list (json/string () "")))
                                                                   (make-operation/replace-selection printer-input `((the sequence (elements-of (the json/array document)))
                                                                                                                     (the json/string (elt (the sequence document) ,index))
                                                                                                                     (the string (value-of (the json/string document)))
                                                                                                                     (the string (subseq (the string document) 0 0))))))))
                      ((gesture/keyboard/key-press #\[)
                       :domain "JSON" :description "Inserts an empty array"
                       :operation (bind ((index (length (elements-of printer-input))))
                                    (make-operation/compound (list (make-operation/sequence/replace-range printer-input
                                                                                                          `((the sequence (elements-of (the json/array document)))
                                                                                                            (the sequence (subseq (the sequence document) ,index ,index)))
                                                                                                          (list (json/array () (json/insertion ()))))
                                                                   (make-operation/replace-selection printer-input `((the sequence (elements-of (the json/array document)))
                                                                                                                     (the json/array (elt (the sequence document) ,index))
                                                                                                                     (the sequence (elements-of (the json/array document)))
                                                                                                                     (the json/insertion (elt (the sequence document) 0))
                                                                                                                     (the string (value-of (the json/insertion document)))
                                                                                                                     (the string (subseq (the string document) 0 0)))))))))
                    (command/read-backward recursion input printer-iomap 'backward-mapper/json/array->tree/node nil)
                    (make-command/nothing (gesture-of input)))))

(def reader json/object-entry->tree/node (projection recursion input printer-iomap)
  (declare (ignore projection))
  (bind ((printer-input (input-of printer-iomap))
         (operation-mapper (lambda (operation selection child-selection child-iomap)
                             (declare (ignore child-selection child-iomap))
                             (typecase operation
                               (operation/text/replace-range
                                (pattern-case selection
                                  (((the string (key-of (the json/object-entry document)))
                                    (the string (subseq (the string document) ?start-index ?end-index)))
                                   (make-operation/sequence/replace-range printer-input selection (replacement-of operation)))
                                  (((the tree/node (printer-output (the json/object-entry document) ?projection ?recursion)) . ?rest)
                                   (make-operation/sequence/replace-range printer-input
                                                                          '((the string (key-of (the json/object-entry document)))
                                                                            (the string (subseq (the string document) 0 0)))
                                                                          (replacement-of operation)))))))))
    (merge-commands (command/read-selection recursion input printer-iomap 'forward-mapper/json/object-entry->tree/node 'backward-mapper/json/object-entry->tree/node)
                    (gesture-case (gesture-of input)
                      ((gesture/keyboard/key-press #\: :shift)
                       :domain "JSON" :description "Moves the selection to the value of the JSON object entry"
                       :operation (pattern-case (selection-of printer-input)
                                    (((the string (key-of (the json/object-entry document))) . ?rest)
                                     ;; TODO: this is quite fragile
                                     (bind ((command (recurse-reader recursion (make-command (gesture-of input) (make-operation/replace-selection (value-of printer-input) `((the text/text (content-of (the tree/leaf document)))
                                                                                                                                                                             (the text/text (text/subseq (the text/text document) 0 0))))
                                                                                             :domain "JSON")
                                                                     (elt (child-iomaps-of printer-iomap) 0)))
                                            (operation (operation-of command)))
                                       (when (typep operation 'operation/replace-selection)
                                         (make-operation/replace-selection printer-input (append `((the ,(form-type (value-of printer-input)) (value-of (the json/object-entry document)))) (selection-of operation)))))))))
                    (command/read-backward recursion input printer-iomap 'backward-mapper/json/object-entry->tree/node operation-mapper)
                    (make-command/nothing (gesture-of input)))))

(def reader json/object->tree/node (projection recursion input printer-iomap)
  (declare (ignore projection))
  (bind ((printer-input (input-of printer-iomap)))
    (merge-commands (command/read-selection recursion input printer-iomap 'forward-mapper/json/object->tree/node 'backward-mapper/json/object->tree/node)
                    (gesture-case (gesture-of input)
                      ((gesture/keyboard/key-press #\" :shift)
                       :domain "JSON" :description "Inserts a new entry into the entries of the JSON object"
                       :operation (bind ((index (length (entries-of printer-input))))
                                    (make-operation/compound (list (make-operation/sequence/replace-range printer-input
                                                                                                          `((the sequence (entries-of (the json/object document)))
                                                                                                            (the sequence (subseq (the sequence document) ,index ,index)))
                                                                                                          (list (json/object-entry () "" (json/insertion ()))))
                                                                   (make-operation/replace-selection printer-input `((the sequence (entries-of (the json/object document)))
                                                                                                                     (the json/object-entry (elt (the sequence document) ,index))
                                                                                                                     (the string (key-of (the json/object-entry document)))
                                                                                                                     (the string (subseq (the string document) 0 0))))))))
                      ((gesture/keyboard/key-press #\,)
                       :domain "JSON" :description "Inserts a new entry into the entries of the JSON object"
                       :operation (bind ((index (length (entries-of printer-input))))
                                    (make-operation/compound (list (make-operation/sequence/replace-range printer-input
                                                                                                          `((the sequence (entries-of (the json/object document)))
                                                                                                            (the sequence (subseq (the sequence document) ,index ,index)))
                                                                                                          (list (json/object-entry () "" (json/insertion ()))))
                                                                   (make-operation/replace-selection printer-input `((the sequence (entries-of (the json/object document)))
                                                                                                                     (the json/object-entry (elt (the sequence document) ,index))
                                                                                                                     (the string (key-of (the json/object-entry document)))
                                                                                                                     (the string (subseq (the string document) 0 0))))))))
                      ((gesture/keyboard/key-press :sdl-key-insert)
                       :domain "JSON" :description "Starts an insertion into the entries of the JSON object"
                       :operation (bind ((entries-length (length (entries-of printer-input))))
                                    (make-operation/compound (list (make-operation/sequence/replace-range printer-input `((the sequence (entries-of (the json/object document)))
                                                                                                                          (the sequence (subseq (the sequence document) ,entries-length ,entries-length)))
                                                                                                          (list (document/insertion)))
                                                                   (make-operation/replace-selection printer-input `((the sequence (entries-of (the json/object document)))
                                                                                                                     (the document/insertion (elt (the sequence document) ,entries-length))
                                                                                                                     (the string (value-of (the document/insertion document)))
                                                                                                                     (the string (subseq (the string document) 0 0))))))))
                      #+nil
                      ((gesture/keyboard/key-press :sdl-key-tab)
                       :domain "JSON" :description "Moves the selection to the next entry of the JSON object"
                       :operation (pattern-case (selection-of printer-input)
                                    (((the sequence (entries-of (the json/object document))) . ?rest)
                                     (pattern-case (selection-of (entries-of input))
                                       (((the ?entry-type (elt (the sequence document) ?entry-index)) . ?rest)
                                        (make-operation/replace-selection printer-input `((the sequence (entries-of (the json/object document)))
                                                                                          (the json/object-entry (elt (the sequence document) ,index))
                                                                                          (the string (key-of (the json/object-entry document)))
                                                                                          (the string (subseq (the string document) 0 0))))))))))
                    (command/read-backward recursion input printer-iomap 'backward-mapper/json/object->tree/node nil)
                    (make-command/nothing (gesture-of input)))))
