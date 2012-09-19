(defparameter *service-path-delimiter* "-")
(defparameter *service-monitor-delimiter* "/")

;;;;;;;;;;;;;;;;;;;;  sim-queue ;;;;;;;;;;;;;;;;;;;;

(defclass sim-queue ()
  ((messages :accessor messages :initarg :messages :initform nil)
   (last-cons :accessor last-cons :initarg :last-cons :initform nil
              :documentation "Cached end of the list")
   (len :accessor len :initarg :len :initform 0
        :documentation "Cached message queue length. Modified by enqueue and dequeue")
   (lock :initform (make-lock) :accessor lock
         :documentation "Lock for this message queue")
   (max-len :accessor max-len :initarg :max-len :initform nil
            :documentation "If present, queue maintains at most this many elements")))

(defun make-queue (&optional max-len)
  (make-instance 'sim-queue :max-len max-len))

(defmethod full-p ((queue sim-queue))
  (with-slots (len max-len lock) queue
    (with-lock-grabbed (lock)
      (and max-len (>= len max-len)))))

(defmethod empty-p ((queue sim-queue))
  (with-slots (len lock) queue
    (with-lock-grabbed (lock)
      (= (len queue) 0))))

(defmethod enqueue (object (queue sim-queue))
  "Adds an element to the back of the given queue in a thread-safe way. If full, dequeue"
  (with-slots (lock messages max-len len last-cons) queue
    (with-lock-grabbed (lock)
      (let ((o (list object)))
        (cond ((empty-p queue)
               (setf messages o
                     last-cons messages
                     len 1))
              ((full-p queue)
               (pop messages)
               (setf (cdr last-cons) o
                     last-cons o))
              (t (setf (cdr last-cons) o
                       last-cons o)
                 (incf len)))))
    (values messages len)))

(defmethod dequeue ((queue sim-queue))
  "Pops a message from the given queue in a thread-safe way."
  (with-slots (messages lock len) queue
    (with-lock-grabbed (lock)
      (if (= len 0)
          (values nil nil)
          (progn
            (decf len)
            (values (pop messages) len))))))

;;;;;;;;;;;;;;;;;  service  ;;;;;;;;;;;;;;;;;;;;;;;

(defstruct service
  name  ; string, like "aa-bb-cc"
  holder
  parent
  belong-tree
  check-rules
  (description  "No description.")
  (monitors (make-hash-table :test #'equalp))
  (subservices (make-hash-table :test #'equalp)))  ; using hashtable to store, service full path like "aa-bb-cc" has "aa-bb-cc-dd"

(defstruct service-tree
  (lock (ccl:make-lock))
  (services (make-hash-table :test #'equalp))
  (monitors (make-hash-table :test #'equalp)))

(defun find-holder (service)
  (if (service-parent service) ; has parent
      (or (service-holder service)
          (find-holder (service-parent service)))
      (service-holder service)))

(defun find-check-rules (service)
  (if (service-parent service) ; has parent
      (or (service-check-rules service)
          (find-check-rules (service-parent service)))
      (service-check-rules service)))

(defun path-list-from-string (str)
  (cl-ppcre:split *service-path-delimiter* str))

(defun string-from-path-list (path-list)
  (if (null path-list)
      nil
      (reduce (lambda (x y) (concatenate 'string x *service-path-delimiter* y)) path-list)))

(defun super-service-from-str (path-str)
  (let* ((v-path-list (reverse (path-list-from-string path-str)))
         (last-name (pop v-path-list)))
    (values (string-from-path-list (reverse v-path-list)) last-name)))

(defun path-and-prefix (path-str)
  (let* ((path-list (path-list-from-string path-str))
         (all-prefix (reverse (maplist #'reverse (reverse path-list))))
         (all-prefix-str (mapcar #'string-from-path-list all-prefix)))
    (values all-prefix all-prefix-str)))

(defun get-subservice (service subservice-short-name)
  "Get subservcie by name, if not exists, generate it."
  (let* ((supername (service-name service))
         (subname   (concatenate 'string supername *service-path-delimiter* subservice-short-name)))
    (or (gethash subname (service-subservices service))
        (let ((subservice (make-service :name subname :parent service :belong-tree (service-belong-tree service))))
          (setf (gethash subname (service-subservices service)) subservice)
          subservice))))

(defun service-from-name-str (service-tree service-name)
  (multiple-value-bind (super-name last-name) (super-service-from-str service-name)
    (or (gethash service-name (service-tree-services service-tree))
        (let ((s
               (if (null super-name) ; top level path like "aa", and not exist
                   (make-service :name last-name :belong-tree service-tree)
                   (get-subservice (service-from-name-str service-tree super-name) last-name))))
          (setf (gethash service-name (service-tree-services service-tree)) s)))))


;;;;;;;;;;;;;     monitor         ;;;;;;;;;;;;;;;;;

(deftype monitor-state () '(OK ERROR WARN TIMEOUT))


(defstruct monitor-item
  (history (make-queue 100))
  (timeout 1200)
  name
  service
  care
  frozen
  (lock (ccl:make-lock)))


(defun monitor-data-from-alist (alist)
  (alexandria:alist-hash-table alist :test #'equalp))


(defun monitor-from-str (service-tree service-path monitor-name)
  (let ((monitor-path (concatenate 'string service-path *service-monitor-delimiter* monitor-name))
        (service (service-from-name-str service-tree service-path)))
    (or (gethash monitor-path (service-tree-monitors service-tree))
        (let ((monitor (make-monitor-item :name monitor-name :service service)))
          (setf (gethash monitor-name (service-monitors service)) monitor)
          (setf (gethash monitor-path (service-tree-monitors service-tree)) monitor)
          monitor))))

(defun add-monitor-data (service-tree service-name monitor-name monitor-data-alist)
  (let ((monitor (monitor-from-str service-tree service-name monitor-name))
        (monitor-data (monitor-data-from-alist monitor-data-alist)))
    (enqueue monitor-data (monitor-item-history monitor))))




;;;;;;;;;;;;      actions      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun msg-send (mobile-number message)
  (let ((uri (format nil "http://192.168.10.25/database.php?phoneno=~A&content=~A" mobile-number (hunchentoot:url-encode message))))
    (trivial-http:http-get uri)))

;;;;;;;;;;;;      rules        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defstruct person
  name
  mobile
  email)

(defstruct holder-group
  people)


