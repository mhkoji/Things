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
