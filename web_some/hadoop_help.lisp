;; /home/wizard/quicklisp/dists/quicklisp/software/hunchentoot-1.1.1/test/test-handlers.lisp
(require 'hunchentoot)
(require 'cl-store)
(require 'cl-fad)
(require :html-template)
(require :elephant)
(use-package :elephant)


(defpackage :hadoop
  (:use :cl :cl-ppcre :hunchentoot  :cl-store)
  (:export #:main))
(in-package :hadoop)

(defun init-env ()
                                        ; for web utf8
  (setf *default-content-type* "text/html; charset=utf-8")
  (setf *hunchentoot-default-external-format*
        (flex:make-external-format :utf-8 :eol-style :lf))
  (setf hunchentoot:*hunchentoot-default-external-format* hunchentoot::+utf-8+) ; for sbcl
  (setf *show-lisp-errors-p* T)
                                        ;(setf *show-lisp-backtraces-p* T) ; no such symbol
  (setf *elephant-store* (elephant:open-store '(:clsql (:sqlite3 "/tmp/blog.db")))) ; for db

                                        ;for html template
  (setf html-template:*default-template-pathname* (pathname "/home/wizard/pro/lisp/templates/"))
                                        ;for http log
  (setf *message-log-pathname* "/tmp/lisp-http-message.log")
  (setf *access-log-pathname*  "/tmp/lisp-http-access.log")
  (setf *log-lisp-errors-p* t)
  (setf *log-lisp-backtraces-p* t)
  )

;; for deploy

(defun re-init-swank (path)
  (load (format nil "~a~a" path "swank-loader.lisp"))
  (setf swank-loader:*source-directory* (format nil "~a" path))
  (setf swank-loader:*fasl-directory* (format nil "~a" path))
  (swank-loader:init :reload t)
  (swank-loader:init :reload t :delete t)
  (funcall (read-from-string "swank:start-server") "/tmp/slime.8346" :coding-system "utf-8-unix")) ;only funcall is working, (swank:start-server ..) doesn't


(defun start-server (&optional (port 8346))
  (init-env)
  (setf *acceptor* (make-instance 'hunchentoot:acceptor :port port))
  ;; make a folder dispatcher the last item of the dispatch table
  ;; if a request doesn't match anything else, try it from the filesystem
  (setf (alexandria:last-elt hunchentoot:*dispatch-table*)
        (hunchentoot:create-folder-dispatcher-and-handler "/" (truename "www")))
  (hunchentoot:start *acceptor*))


(defun template-to-page (template &optional (arguments ()))
  (push (create-prefix-dispatcher (format nil "/~a" template)
                                  (lambda ()
                                    (with-output-to-string (sss)
                                      (html-template:fill-and-print-template
                                       (pathname (format nil "~a/~a" html-template:*default-template-pathname* template))
                                       arguments
                                       :stream sss))))
        *dispatch-table*))

