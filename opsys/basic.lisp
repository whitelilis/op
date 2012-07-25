(in-package :opsys)


(defmacro with-follower (filename local-let begin mid)
  "Follow a file by name, still running. Designed for log parsing."
  `(let (,@local-let)
     (with-open-stream (stream  (process-output (sb-ext:run-program "/bin/bash" (list "-c" (format nil "~a ~a" "tail -F" ,filename)) :output :stream :wait nil)))
       ,@begin
       (loop for line = (read-line stream nil 'eof)
          until (eq line 'eof)
          do (progn
               ,@mid)))))



(defmacro with-thread (&body body)
  `(sb-thread:make-thread (lambda () ,body)))
