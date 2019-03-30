(defpackage :things.obj
  (:use :cl))
(in-package :things.obj)
(ql:quickload :alexandria)

(defmacro with-$ ((var value) &body body)
  (let (($sym (intern (format nil "$~A" var))))
    `(let ((,var ,value))
       (labels ((,$sym (&rest args)
                  (apply ,var args)))
         ,@body))))

(defun make-obj ()
  (let ((num 0))
    (lambda (msg &rest args)
      (ecase msg
        (:get num)
        (:set (let ((new-num (car args)))
                (setf num new-num)))))))

(with-$ (o (make-obj))
  (print ($o :get))
  ($o :set 20)
  (print ($o :get)))
