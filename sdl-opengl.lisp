(defpackage :things.sdl-opengl
  (:use :cl)
  (:export :hello
           :pyramid))
(in-package :things.sdl-opengl)
(ql:quickload :lispbuilder-sdl)
(ql:quickload :cl-opengl)

(defun %hello ()
  (sdl:with-init ()
    (sdl:window 480 640
                :title-caption "Hello"
                :opengl t
                :opengl-attributes (list :sdl-gl-doublebuffer 1))
    (setf (sdl:frame-rate) 60)
    (progn
      (gl:clear-color 0 0 0 0)
      (gl:matrix-mode :projection)
      (gl:load-identity)
      (gl:ortho 0 1 0 1 -1 1))
    (sdl:with-events ()
      (:quit-event () t)
      (:video-expose-event ()
        (sdl:update-display))
      (:key-down-event (:key key)
        (cond ((sdl:key= key :sdl-key-escape)
               (sdl:push-quit-event))))
      (:idle ()
        (progn
          (gl:clear :color-buffer)
          (gl:color 1 1 1)
          (gl:with-primitive :polygon
            (gl:vertex 0.25 0.25 0)
            (gl:vertex 0.75 0.25 0)
            (gl:vertex 0.75 0.75 0)
            (gl:vertex 0.25 0.75 0)))
        (sdl:update-display)))))

(defun hello ()
  #+sbcl
  (sb-int:with-float-traps-masked (:invalid :inexact)
    (%hello))
  #-sbcl
  (%hello))

;;;

(defun %pyramid ()
  (sdl:with-init ()
    (sdl:window 480 360
                :title-caption "Pyramid"
                :opengl t
                :opengl-attributes (list :sdl-gl-doublebuffer 1))
    (setf (sdl:frame-rate) 60)
    (progn
      (gl:matrix-mode :projection)
      (gl:load-identity)
      (gl:frustum 1 -1 -1 1 2 10)
      (gl:light :light0 :position (list 3 0 -2 0))
      (gl:light :light0 :diffuse (list 1 0 0 1))
      (gl:enable :lighting)
      (gl:enable :light0)
      (gl:enable :depth-test))
    (sdl:with-events ()
      (:quit-event () t)
      (:video-expose-event ()
        (sdl:update-display))
      (:key-down-event (:key key)
        (cond ((sdl:key= key :sdl-key-escape)
               (sdl:push-quit-event))))
      (:idle ()
        (progn
          (gl:clear :color-buffer :depth-buffer)
          (gl:with-primitive :polygon
            (gl:normal  3    0 -2)
            (gl:vertex  0 -0.9 -2)
            (gl:vertex  3 -0.9 -7)
            (gl:vertex  0  0.9 -2)

            (gl:normal -3    9 -2)
            (gl:vertex  0 -0.9 -2)
            (gl:vertex -3 -0.9 -7)
            (gl:vertex  0  0.9 -2)))
        (sdl:update-display)))))

(defun pyramid ()
  #+sbcl
  (sb-int:with-float-traps-masked (:invalid :inexact)
    (%pyramid))
  #-sbcl
  (%hello))
