;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(in-package :projectured)

;;;;;;
;;; Projection

(def projection preserving ()
  ())

;;;;;;
;;; Construction

(def (function e) make-projection/preserving ()
  (make-projection 'preserving))

;;;;;;
;;; Construction

(def (macro e) preserving ()
  '(make-projection/preserving))

;;;;;;
;;; Printer

(def printer preserving (projection recursion iomap input input-reference output-reference)
  (declare (ignore iomap))
  (if (stringp input)
      (make-iomap/compound projection recursion input input-reference input output-reference
                            (list (make-iomap/object projection recursion input input-reference input output-reference)
                                  (make-iomap/string input input-reference 0 input output-reference 0 (length input))))
      (make-iomap/object projection recursion input input-reference input output-reference)))

;;;;;;
;;; Reader

(def reader preserving (projection recursion printer-iomap projection-iomap gesture-queue operation document)
  (declare (ignore projection recursion printer-iomap projection-iomap gesture-queue document))
  operation)
