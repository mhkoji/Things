(defpackage :things.mop
  (:use :cl))
(in-package :things.mop)

(defgeneric show (x))

#+sbcl
(progn
  (defun call-with-context (callback)
    (let ((method
           (multiple-value-bind (meth args)
               (sb-mop:make-method-lambda
                (sb-mop:class-prototype (find-class
                                         'standard-generic-function))
                (sb-mop:class-prototype (find-class
                                         'standard-method))
                '(lambda (x)
                  (format t "Show string of ~A~%" x))
                nil)
             (apply #'make-instance 'standard-method
                    :function (compile nil meth)
                    :lambda-list (list 'x)
                    :specializers (list (find-class 'string))
                    args))))
      (let ((gf-show (sb-mop:ensure-generic-function 'show)))
        ;; TODO: need multi-thread support to protect the gf-show object?
        (add-method gf-show method)
        (unwind-protect (funcall callback)
          (remove-method gf-show method)))))

  (call-with-context
   (lambda ()
     (show "Hello!"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; The value printer role
(defgeneric get-value (value-printer))

(defun print-value (value-printer)
  (let ((v (get-value value-printer)))
    (format t "Value printer prints: ~A~%" v)))


;;; The value of a number object
(defun get-number-value (x)
  (format nil "The value of number [~A]" x))


#+sbcl
(progn
  (defmacro with-print-value-context ((class &key get-value) &rest body)
    `(let ((method
            (multiple-value-bind (meth args)
                (sb-mop:make-method-lambda
                 (sb-mop:class-prototype (find-class
                                          'standard-generic-function))
                 (sb-mop:class-prototype (find-class
                                          'standard-method))
                 '(lambda (x)
                   (funcall ,get-value x))
                 nil)
              (apply #'make-instance 'standard-method
                     :function (compile nil meth)
                     :lambda-list (list 'x)
                     :specializers (list (find-class ',class))
                     args))))
       (let ((gf (sb-mop:ensure-generic-function 'get-value)))
         (add-method gf method)
         (unwind-protect (progn ,@body)
           (remove-method gf method)))))

  ;;; Make a number object play the value printer role
  (with-print-value-context (number :get-value #'get-number-value)
    (print-value 10)))
