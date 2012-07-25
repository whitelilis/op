;;;; opsys.asd

(asdf:defsystem #:opsys
  :serial t
  :description "Describe opsys here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :depends-on (#:cl-ppcre)
  :components ((:file "package")
               (:file "basic")
               (:file "opsys")))
