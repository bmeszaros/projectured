;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(in-package :projectured)

;;;;;;
;;; Projection

(def projection list/list->text ()
  ((output-border :type boolean)))

;;;;;;
;;; Construction

(def function make-projection/list/list->text ()
  (make-projection 'list/list->text :output-border #f))

;;;;;;
;;; Construction

(def macro list/list->text ()
  '(make-projection/list/list->text))

;;;;;;
;;; Printer

;; TODO: work with text internally
(def printer list/list->text (projection recursion input input-reference)
  (bind ((child-iomaps nil)
         (typed-input-reference `(the ,(form-type input) ,input-reference))
         (elements (elements-of input))
         (element-iomaps (iter (for index :from 0)
                               (for element :in-sequence elements)
                               (collect (recurse-printer recursion (content-of element)
                                                         `((content-of (the list/element document))
                                                           (the list/element (elt (the sequence document) ,index))
                                                           (the sequence (elements-of (the list/list document)))
                                                           ,@(typed-reference (form-type input) input-reference))))))
         (width (iter (for element-iomap :in element-iomaps)
                      (maximizing (text/length (output-of element-iomap)))))
         (output (text/text ()
                   (text/string
                    (with-output-to-string (stream)
                      (iter (for element-index :from 0)
                            (for element-iomap :in element-iomaps)
                            (for content = (output-of element-iomap))
                            (for element-reference = `(elt (the sequence (elements-of (the list/list ,input-reference))) ,element-index))
                            (when (output-border-p projection)
                              (if (first-iteration-p)
                                  (progn
                                    (write-char #\U250C stream)
                                    (iter (repeat width)
                                          (write-char #\U2500 stream))
                                    (write-char #\U2510 stream))
                                  (progn
                                    (write-char #\U251C stream)
                                    (iter (repeat width)
                                          (write-char #\U2500 stream))
                                    (write-char #\U2524 stream))))
                            (terpri stream)
                            (when (output-border-p projection)
                              (write-char #\U2502 stream))
                            (write-string (text/as-string content) stream)
                            (write-string (make-string-of-spaces (- width (text/length content))) stream)
                            (when (output-border-p projection)
                              (write-char #\U2502 stream))
                            (terpri stream))
                      (when (output-border-p projection)
                        (write-char #\U2514 stream)
                        (iter (repeat width)
                              (write-char #\U2500 stream))
                        (write-char #\U2518 stream)))))))
    (make-iomap/compound projection recursion input input-reference output
                         (list* (make-iomap/object projection recursion input input-reference output) (nreverse child-iomaps)))))

;;;;;;
;;; Reader

(def reader list/list->text (projection recursion input printer-iomap)
  (declare (ignore projection recursion))
  input)
