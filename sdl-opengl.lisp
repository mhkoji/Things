(defpackage :things.sdl-opengl
  (:use :cl)
  (:export :main))
(in-package :things.sdl-opengl)
(ql:quickload :lispbuilder-sdl)
(ql:quickload :cl-opengl)

(defun %main ()
  (sdl:with-init ()
    (sdl:window 480 640
                :title-caption "SDL OPENGL"
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


(defun main ()
  #+sbcl
  (sb-int:with-float-traps-masked (:invalid :inexact)
    (%main))
  #-sbcl
  (%main))
