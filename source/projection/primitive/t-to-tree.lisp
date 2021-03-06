;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(in-package :projectured)

;;;;;;
;;; Projection

(def projection t/sequence->tree/node ()
  ())

(def projection t/object->tree/node ()
  ((slot-provider :type function)))

;;;;;;
;;; Construction

(def function make-projection/t/sequence->tree/node ()
  (make-projection 't/sequence->tree/node))

(def function make-projection/t/object->tree/node (&key slot-provider)
  (make-projection 't/object->tree/node :slot-provider (or slot-provider
                                                           ;; TODO: default
                                                           (lambda (instance)
                                                             (remove-if (lambda (slot) (member (slot-definition-name slot) '(projection selection raw font font-color stroke-color fill-color line-color))) (class-slots (class-of instance))))
                                                           #+nil
                                                           (compose 'class-slots 'class-of))))

;;;;;;
;;; Construction

(def macro t/sequence->tree/node ()
  '(make-projection/t/sequence->tree/node))

(def macro t/object->tree/node (q&key slot-provider)
  `(make-projection/t/object->tree/node :slot-provider ,slot-provider))

;;;;;;
;;; Printer

(def printer t/sequence->tree/node (projection recursion input input-reference)
  (bind ((element-iomaps (as (iter (for index :from 0)
                                   (for element :in-sequence input)
                                   (collect (recurse-printer recursion element
                                                             `((elt (the ,(form-type input) document) ,index)
                                                               ,@(typed-reference (form-type input) input-reference)))))))
         (output-selection (as (when (typep input 'document)
                                 (pattern-case (reverse (selection-of input))
                                   (((the ?element-type (elt (the sequence document) ?index)) . ?rest)
                                    (bind ((element-iomap (elt (va element-iomaps) ?index))
                                           (element-iomap-output (output-of element-iomap)))
                                      (append (selection-of element-iomap-output)
                                              `((the ,(form-type element-iomap-output) (elt (the sequence document) 1))
                                                (the sequence (children-of (the tree/node document)))
                                                (the tree/node (elt (the sequence document) ,(1+ ?index)))
                                                (the sequence (children-of (the tree/node document)))))))
                                   (((the tree/node (printer-output (the ?type document) ?projection ?recursion)) . ?rest)
                                    (when (and (eq projection ?projection) (eq recursion ?recursion))
                                      (reverse ?rest)))))))
         (output (as (if (emptyp input)
                         (tree/leaf (:selection (va output-selection))
                           (text/text (:selection (butlast (va output-selection)))
                             (text/string "")))
                         (make-tree/node (list* (tree/leaf (:selection (butlast (va output-selection) 2))
                                                  (text/text (:selection (butlast (va output-selection) 3))
                                                    (text/string (if (consp input) "LIST" "SEQUENCE") :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/red*)))
                                                (iter (for index :from 0)
                                                      (for element-iomap :in (va element-iomaps))
                                                      (for element-iomap-output = (output-of element-iomap))
                                                      (collect (tree/node (:indentation 1 :separator (text/text () (text/string " " :font *font/ubuntu/monospace/regular/24*))
                                                                                        :selection (butlast (va output-selection) 2))
                                                                 (tree/leaf (:selection (butlast (va output-selection) 4))
                                                                   (text/text (:selection (butlast (va output-selection) 5))
                                                                     (text/string (write-to-string index) :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/magenta*)))
                                                                 element-iomap-output))))
                                         :separator (text/text () (text/string " " :font *font/ubuntu/monospace/regular/24*))
                                         :selection (va output-selection))))))
    (make-iomap/compound projection recursion input input-reference output element-iomaps)))

(def printer t/object->tree/node (projection recursion input input-reference)
  (bind ((class (class-of input))
         (slots (funcall (slot-provider-of projection) input))
         (slot-readers (mapcar (curry 'find-slot-reader class) slots))
         (slot-iomaps (as (iter (for slot :in slots)
                                (for slot-reader :in slot-readers)
                                (collect (when (slot-boundp-using-class class input slot)
                                           (recurse-printer recursion (slot-value-using-class class input slot)
                                                            `((,slot-reader (the ,(form-type input) document))
                                                              ,@(typed-reference (form-type input) input-reference))))))))
         (output-selection (as (when (typep input 'document)
                                 (pattern-case (reverse (selection-of input))
                                   (((the ?type document))
                                    `((the tree/node document)))
                                   (((the string (?slot-reader (the ?input-type document)))
                                     (the string (subseq (the string document) ?start-index ?end-index)))
                                    (bind ((index (position ?slot-reader slot-readers)))
                                      (when index
                                        (bind ((slot-iomap (elt (va slot-iomaps) index))
                                               (slot-iomap-output (output-of slot-iomap)))
                                          (append `((the text/text (text/subseq (the text/text document) ,(1+ ?start-index) ,(1+ ?end-index)))
                                                    (the text/text (content-of (the tree/leaf document)))
                                                    (the tree/leaf (elt (the sequence document) ,(* 2 (1+ index))))
                                                    (the sequence (children-of (the tree/node document))))
                                                  (selection-of slot-iomap-output))))))
                                   (((the number (?slot-reader (the ?input-type document)))
                                     (the string (write-to-string (the number document)))
                                     (the string (subseq (the string document) ?start-index ?end-index)))
                                    (bind ((index (position ?slot-reader slot-readers)))
                                      (when index
                                        (bind ((slot-iomap (elt (va slot-iomaps) index))
                                               (slot-iomap-output (output-of slot-iomap)))
                                          (append `((the text/text (text/subseq (the text/text document) ,?start-index ,?end-index))
                                                    (the text/text (content-of (the tree/leaf document)))
                                                    (the tree/leaf (elt (the sequence document) ,(* 2 (1+ index))))
                                                    (the sequence (children-of (the tree/node document))))
                                                  (selection-of slot-iomap-output))))))
                                   (((the ?slot-value-type (?slot-reader (the ?input-type document))) . ?rest)
                                    (bind ((index (position ?slot-reader slot-readers))
                                           (slot-iomap (elt (va slot-iomaps) index))
                                           (slot-iomap-output (output-of slot-iomap)))
                                      (append (selection-of slot-iomap-output)
                                              `((the ,(if (typep slot-iomap-output 'tree/base)
                                                          (form-type slot-iomap-output)
                                                          'tree/leaf)
                                                     (elt (the sequence document) ,(* 2 (1+ index))))
                                                (the sequence (children-of (the tree/node document)))))))
                                   (((the tree/node (printer-output (the ?type document) ?projection ?recursion)) . ?rest)
                                    (when (and (eq projection ?projection) (eq recursion ?recursion))
                                      (reverse ?rest)))))))
         (output (as (make-tree/node (list* (tree/leaf (:selection (butlast (va output-selection) 2))
                                              (text/text (:selection (butlast (va output-selection) 3))
                                                (text/string (symbol-name (class-name (class-of input))) :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/red*)))
                                            (iter (for slot :in slots)
                                                  (for slot-iomap :in (va slot-iomaps))
                                                  (collect (tree/leaf (:selection (butlast (va output-selection) 2) :indentation 1)
                                                             (text/text (:selection (butlast (va output-selection) 3))
                                                               (text/make-string (symbol-name (slot-definition-name slot)) :font *font/ubuntu/monospace/regular/24* :font-color *color/solarized/blue*))))
                                                  (when (slot-boundp-using-class class input slot)
                                                    (bind ((slot-iomap-output (output-of slot-iomap)))
                                                      (if (typep slot-iomap-output 'tree/base)
                                                          (progn
                                                            (when (typep slot-iomap-output 'tree/node)
                                                              (setf (indentation-of slot-iomap-output) 2))
                                                            (collect slot-iomap-output))
                                                          (progn
                                                            (when (typep slot-iomap-output 'document)
                                                              (setf (selection-of slot-iomap-output) (butlast (va output-selection) 3)))
                                                            (collect (tree/leaf (:selection (butlast (va output-selection) 2) :opening-delimiter (text/text () (text/string " " :font *font/ubuntu/monospace/regular/24*)))
                                                                       slot-iomap-output))))))))
                                     :selection (va output-selection)))))
    (make-iomap/compound projection recursion input input-reference output slot-iomaps)))

;;;;;;
;;; Reader

(def reader t/sequence->tree/node (projection recursion input printer-iomap)
  (bind ((printer-input (input-of printer-iomap)))
    (merge-commands (when (typep printer-input 'document)
                      (pattern-case (reverse (selection-of printer-input))
                        (((the ?element-type (elt (the sequence document) ?index)) . ?rest)
                         (bind ((output-operation (operation-of (recurse-reader recursion (make-command/nothing (gesture-of input)) (elt (child-iomaps-of printer-iomap) ?index)))))
                           (labels ((recurse (operation)
                                      (typecase operation
                                        (operation/functional operation)
                                        (operation/replace-selection
                                         (make-operation/replace-selection printer-input
                                                                           (append (selection-of operation)
                                                                                   `((the ,?element-type (elt (the sequence document) ,?index))))))
                                        (operation/replace-target
                                         (make-operation/replace-target printer-input
                                                                        (append (selection-of operation)
                                                                                `((the ,?element-type (elt (the sequence document) ,?index))))
                                                                        (replacement-of operation)))
                                        (operation/sequence/replace-range
                                         (make-operation/sequence/replace-range printer-input
                                                                                        (append (selection-of operation)
                                                                                                `((the ,?element-type (elt (the sequence document) ,?index))))
                                                                                        (replacement-of operation)))
                                        (operation/number/replace-range
                                         (make-operation/number/replace-range printer-input
                                                                              (append (selection-of operation)
                                                                                      `((the ,?element-type (elt (the sequence document) ,?index))))
                                                                              (replacement-of operation)))
                                        (operation/compound
                                         (bind ((operations (mapcar #'recurse (elements-of operation))))
                                           (unless (some 'null operations)
                                             (make-operation/compound operations)))))))
                             (awhen (recurse output-operation)
                               (make-command (gesture-of input) it
                                             :domain (domain-of input)
                                             :description (description-of input))))))))
                    (awhen (labels ((recurse (operation)
                                      (typecase operation
                                        (operation/quit operation)
                                        (operation/functional operation)
                                        (operation/replace-selection
                                         (awhen (pattern-case (reverse (selection-of operation))
                                                  (((the sequence (children-of (the tree/node document)))
                                                    (the tree/node (elt (the sequence document) ?index))
                                                    (the sequence (children-of (the tree/node document)))
                                                    (the tree/node (elt (the sequence document) 1))
                                                    . ?rest)
                                                   (bind ((index (1- ?index))
                                                          (element (elt printer-input index))
                                                          (input-operation (make-operation/replace-selection element (reverse ?rest)))
                                                          (output-operation (operation-of (recurse-reader recursion (make-command (gesture-of input) input-operation :domain (domain-of input) :description (description-of input)) (elt (child-iomaps-of printer-iomap) index)))))
                                                     (append (selection-of output-operation)
                                                             `((the ,(form-type element) (elt (the sequence document) ,index))))))
                                                  (?a
                                                   (append (selection-of operation) `((the tree/node (printer-output (the ,(form-type printer-input)  document) ,projection ,recursion))))))
                                           (make-operation/replace-selection printer-input it)))
                                        (operation/sequence/replace-range
                                         (awhen (pattern-case (reverse (selection-of operation))
                                                  (((the sequence (children-of (the tree/node document)))
                                                    (the tree/node (elt (the sequence document) ?index))
                                                    (the sequence (children-of (the tree/node document)))
                                                    (the tree/node (elt (the sequence document) 1))
                                                    . ?rest)
                                                   (bind ((index (1- ?index))
                                                          (element (elt printer-input index))
                                                          (input-operation (make-operation/sequence/replace-range element (reverse ?rest) (replacement-of operation)))
                                                          (output-operation (operation-of (recurse-reader recursion (make-command (gesture-of input) input-operation :domain (domain-of input) :description (description-of input)) (elt (child-iomaps-of printer-iomap) index)))))
                                                     (when (typep output-operation 'operation/sequence/replace-range)
                                                       (append (selection-of output-operation)
                                                               `((the ,(form-type element) (elt (the sequence document) ,index))))))))
                                           (make-operation/sequence/replace-range printer-input it (replacement-of operation))))
                                        (operation/show-context-sensitive-help
                                         (make-instance 'operation/show-context-sensitive-help
                                                        :commands (iter (for command :in (commands-of operation))
                                                                        (awhen (recurse (operation-of command))
                                                                          (collect (make-instance 'command
                                                                                                  :gesture (gesture-of command)
                                                                                                  :domain (domain-of command)
                                                                                                  :description (description-of command)
                                                                                                  :operation it))))))
                                        (operation/compound
                                         (bind ((operations (mapcar #'recurse (elements-of operation))))
                                           (unless (some 'null operations)
                                             (make-operation/compound operations)))))))
                             (recurse (operation-of input)))
                      (make-command (gesture-of input) it
                                    :domain (domain-of input)
                                    :description (description-of input)))
                    (make-command/nothing (gesture-of input)))))

(def reader t/object->tree/node (projection recursion input printer-iomap)
  (bind ((printer-input (input-of printer-iomap)))
    (merge-commands (when (typep printer-input 'document)
                      (pattern-case (reverse (selection-of printer-input))
                        (((the ?slot-value-type (?slot-reader (the ?type document))) . ?rest)
                         (bind ((slot-value (funcall ?slot-reader printer-input))
                                (class (class-of printer-input))
                                (slots (funcall (slot-provider-of projection) printer-input))
                                (slot-readers (mapcar (curry 'find-slot-reader class) slots))
                                (element-index (position ?slot-reader slot-readers)))
                           (when element-index
                             (bind ((output-operation (operation-of (recurse-reader recursion (make-command/nothing (gesture-of input)) (elt (child-iomaps-of printer-iomap) element-index)))))
                               (awhen (operation/extend printer-input `((the ,(form-type slot-value) (,?slot-reader (the ,(form-type printer-input) document)))) output-operation)
                                 (make-command (gesture-of input) it
                                               :domain (domain-of input)
                                               :description (description-of input)))))))))
                    (gesture-case (gesture-of input)
                      ((gesture/keyboard/key-press :sdl-key-p :control)
                       :domain "JSON" :description "Switches to domain specific projection"
                       :operation (make-operation/functional (lambda () (setf (projection-of printer-input) (if (projection-of printer-input) nil (recursive (make-projection/json->tree))))))))
                    (awhen (labels ((recurse (operation)
                                      (typecase operation
                                        (operation/quit operation)
                                        (operation/functional operation)
                                        (operation/replace-selection
                                         (awhen (pattern-case (reverse (selection-of operation))
                                                  (((the sequence (children-of (the tree/node document)))
                                                    (the tree/leaf (elt (the sequence document) ?child-index))
                                                    (the text/text (content-of (the tree/leaf document)))
                                                    (the text/text (text/subseq (the text/text document) ?start-index ?end-index)))
                                                   (if (and (evenp ?child-index) (> ?child-index 0))
                                                       (bind ((slot-index (- (/ ?child-index 2) 1))
                                                              (slots (funcall (slot-provider-of projection) printer-input))
                                                              (slot-reader (find-slot-reader (class-of printer-input) (elt slots slot-index))))
                                                         `((the string (subseq (the string document) ,(1- ?start-index) ,(1- ?end-index)))
                                                           (the string (,slot-reader (the ,(form-type printer-input) document)))))
                                                       (append (selection-of operation) `((the tree/node (printer-output (the ,(form-type printer-input)  document) ,projection ,recursion))))))
                                                  (((the sequence (children-of (the tree/node document)))
                                                    (the tree/node (elt (the sequence document) ?index))
                                                    . ?rest)
                                                   (bind ((index (1- (floor ?index 2)))
                                                          (slots (funcall (slot-provider-of projection) printer-input))
                                                          (slot (elt slots index))
                                                          (slot-reader (find-slot-reader (class-of printer-input) slot))
                                                          (slot-value (slot-value-using-class (class-of printer-input) printer-input slot))
                                                          (input-operation (make-operation/replace-selection slot-value (reverse ?rest)))
                                                          (output-operation (operation-of (recurse-reader recursion (make-command (gesture-of input) input-operation :domain (domain-of input) :description (description-of input)) (elt (child-iomaps-of printer-iomap) index)))))
                                                     (append (selection-of output-operation)
                                                             `((the ,(form-type slot-value) (,slot-reader (the ,(form-type printer-input) document)))))))
                                                  (?a
                                                   (append (selection-of operation) `((the tree/node (printer-output (the ,(form-type printer-input)  document) ,projection ,recursion))))))
                                           (make-operation/replace-selection printer-input it)))
                                        (operation/sequence/replace-range
                                         (awhen (pattern-case (reverse (selection-of operation))
                                                  (((the sequence (children-of (the tree/node document)))
                                                    (the tree/leaf (elt (the sequence document) ?child-index))
                                                    (the text/text (content-of (the tree/leaf document)))
                                                    (the text/text (text/subseq (the text/text document) ?start-index ?end-index)))
                                                   (when (and (evenp ?child-index) (> ?child-index 0))
                                                     (bind ((slots (funcall (slot-provider-of projection) printer-input))
                                                            (slot-index (- (/ ?child-index 2) 1))
                                                            (class (class-of printer-input))
                                                            (slot (elt slots slot-index))
                                                            (slot-reader (find-slot-reader class slot))
                                                            (length (+ 2 (length (slot-value-using-class class printer-input slot)))))
                                                       (when (and (< 0 ?start-index length) (< 0 ?end-index length))
                                                         `((the string (subseq (the string document) ,(1- ?start-index) ,(1- ?end-index)))
                                                           (the string (,slot-reader (the ,(form-type printer-input) document))))))))
                                                  (((the sequence (children-of (the tree/node document)))
                                                    (the tree/node (elt (the sequence document) ?index))
                                                    . ?rest)
                                                   (bind ((index (1- (floor ?index 2)))
                                                          (slots (funcall (slot-provider-of projection) printer-input))
                                                          (slot (elt slots index))
                                                          (slot-reader (find-slot-reader (class-of printer-input) slot))
                                                          (slot-value (slot-value-using-class (class-of printer-input) printer-input slot))
                                                          (input-operation (make-operation/sequence/replace-range slot-value (reverse ?rest) (replacement-of operation)))
                                                          (output-operation (operation-of (recurse-reader recursion (make-command (gesture-of input) input-operation :domain (domain-of input) :description (description-of input)) (elt (child-iomaps-of printer-iomap) index)))))
                                                     (when (typep output-operation 'operation/sequence/replace-range)
                                                       (append (selection-of output-operation)
                                                               `((the ,(form-type slot-value) (,slot-reader (the ,(form-type printer-input) document)))))))))
                                           (make-operation/sequence/replace-range printer-input it (replacement-of operation))))
                                        (operation/show-context-sensitive-help
                                         (make-instance 'operation/show-context-sensitive-help
                                                        :commands (iter (for command :in (commands-of operation))
                                                                        (awhen (recurse (operation-of command))
                                                                          (collect (make-instance 'command
                                                                                                  :gesture (gesture-of command)
                                                                                                  :domain (domain-of command)
                                                                                                  :description (description-of command)
                                                                                                  :operation it))))))
                                        (operation/compound
                                         (bind ((operations (mapcar #'recurse (elements-of operation))))
                                           (unless (some 'null operations)
                                             (make-operation/compound operations)))))))
                             (recurse (operation-of input)))
                      (make-command (gesture-of input) it
                                    :domain (domain-of input)
                                    :description (description-of input)))
                    (make-command/nothing (gesture-of input)))))
