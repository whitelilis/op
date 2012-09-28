(defpackage :monitor)

(in-package :monitor)

(require :cl-ppcre)
(require :alexandria)
(require :hunchentoot)
(require :trivial-http)
(require :log4cl)
(require :restas)


(defparameter *service-path-delimiter* "-")
(defparameter *service-monitor-delimiter* "/")
(defparameter *monitor-alive-flag* :alive)
(defparameter *monitor-suspend-flag* :suspend)
(defparameter *monitor-stop-flag* :stop)
(defparameter *default-message* "Nothing")


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
  special-check ; not using the common check function
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



(defstruct monitor-item
  (history (make-queue 100))
  last
  second-last
  third-last
  (timeout 1200)
  context ; hash to store something, some rules or other maybe use it
  name
  service
  special-check  ; not use the common check, check this monitor, only use this monitor as its argument
  (work-p *monitor-alive-flag*) ; used for stop this monitor, or suspend it
  new-data-hook ; fired when new monitor data comes; a function which only use this monitor as its argument
  (lock (ccl:make-lock)))

(defun last-three-new-data (data monitor)
  (with-slots (last second-last third-last) monitor
    (psetf last data
           second-last last
           third-last second-last)))


(defun append-monitor-data (data monitor-item)
  (with-lock-grabbed ((monitor-item-lock monitor-item))
    (enqueue data (monitor-item-history monitor-item))
    (last-three-new-data data  monitor-item)))


(defun alist-key-keywords (alist)
  (mapcar (lambda (atom)
            (let ((k (car atom))
                  (v (cdr atom)))
              (cons (intern (string-upcase (string k)) "KEYWORD")  v))) alist))

(defun monitor-data-from-alist (alist)
  (alexandria:alist-hash-table (alist-key-keywords alist) :test #'equalp))


(defun monitor-from-str (service-tree service-path monitor-name)
  (let ((monitor-path (concatenate 'string service-path *service-monitor-delimiter* monitor-name))
        (service (service-from-name-str service-tree service-path)))
    (or (gethash monitor-path (service-tree-monitors service-tree))
        (let ((monitor (make-monitor-item :name monitor-name :service service)))
          (setf (gethash monitor-name (service-monitors service)) monitor)
          (setf (gethash monitor-path (service-tree-monitors service-tree)) monitor)
          monitor))))


; this is the only using func
(defun add-monitor-data (service-tree service-name monitor-name monitor-data-alist)
  (let ((monitor (monitor-from-str service-tree service-name monitor-name))
        (monitor-data (monitor-data-from-alist monitor-data-alist)))
    (append-monitor-data monitor-data monitor)
    (common-service-check (monitor-item-service monitor))
    (when (monitor-item-new-data-hook monitor)
      (funcall (monitor-item-new-data-hook monitor) monitor))))





;;;;;;;;;;;;      rules        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;  judge-func  ;;;;;;;;;;;;;;;;;;;;

(deftype monitor-state () '(:OK :ERROR :WARN :TIMEOUT))


(defun monitor-last-status (monitor)
  (with-slots (last) monitor
    (if (and monitor last)
        (alexandria:ensure-gethash :status last "OK")
        "OK")))

(defun monitor-second-last-status (monitor)
  (with-slots (second-last) monitor
    (if (and monitor second-last)
        (alexandria:ensure-gethash :status second-last "OK")
        "OK")))


(defun monitor-last-info (monitor)
  (with-slots (last) monitor
    (if (and monitor last)
        (or (gethash :info last)
            (string (monitor-last-status monitor)))
        "OK")))



(defun monitor-second-last-info (monitor)
    (with-slots (second-last) monitor
      (if (and monitor second-last)
          (or (gethash :info second-last)
              (string (monitor-second-last-status monitor)))
          "OK")))


(defun hash-value-list (hash)
  (loop for v being the hash-value of hash collect v))

(defun join-by (join-string str-list)
  (if (null str-list)
      ""
      (reduce (lambda (x y) (concatenate 'string x join-string y)) str-list)))

(defun ok-info-p (info)
  (or (equalp info :OK)
      (equalp info "OK")
      (equalp info *default-message*)))

(defun named-not-ok-info (monitor get-info-func)
  (let ((name (monitor-item-name monitor))
        (info (funcall get-info-func monitor)))
    (if (ok-info-p info)
        ""
        (concatenate 'string name ":" info))))

(defun empty-string (str)
  (equalp str ""))

(defun last-not-ok-info (monitor)
  (named-not-ok-info monitor #'monitor-last-info))

(defun second-last-not-ok-info (monitor)
  (named-not-ok-info monitor #'monitor-second-last-info))

(defun alive-monitor-p (monitor)
  (equalp *monitor-alive-flag* (monitor-item-work-p monitor)))


(defun alive-monitors-info (monitor-list &optional (get-info-func #'last-not-ok-info))
  (let ((raw-info (join-by " " (remove-if #'empty-string
                          (mapcar get-info-func
                                  (remove-if-not #'alive-monitor-p   monitor-list))))))
    (if (empty-string raw-info)
        "All ok"
        raw-info)))

(defun service-alive-monitors-info (service &optional (get-info-func #'last-not-ok-info))
  (alive-monitors-info (hash-value-list (service-monitors service)) get-info-func))



;;;;;;;;;;;;      action-func      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defstruct person
  name
  mobile
  email)

(defstruct holder
  main
  others
  )


;;; cold-reset

;;; msg construct

;;; msg send
(defun msg-send (mobile-number message &key test)
  (when (not test)
    (let ((uri (format nil "http://192.168.10.25/database.php?phoneno=~A&content=~A" mobile-number (hunchentoot:url-encode message))))
      (trivial-http:http-get uri))))


(defun alert-holder (service msg &key (count 1))
  (let ((holder (find-holder service))
        (service-name (service-name service)))
    (when holder
      (mapcar (lambda (person)
                (with-slots (mobile) person
                (when (and holder person  mobile)
                  (dotimes (i count)
                    (msg-send mobile (concatenate 'string "[" service-name "] "  msg) :test t)))))
            (concatenate 'list (list (holder-main holder)) (holder-others holder))))))

(defun common-service-check (service)
  "Check whether any status of this service's monitors changed from it's info. It is satisfy to fire this function when new data comes, because only new data will change state. If use loop check, when no data updata, bad is still bad and ok is still ok."
  (let ((last-info (service-alive-monitors-info service #'last-not-ok-info))
        (second-last-info (service-alive-monitors-info service #'second-last-not-ok-info)))
    (when (not (equalp last-info second-last-info)) ; some thing changed, include ok->not-ok,  not-ok->ok
      (alert-holder service last-info :count 2))))

;;;;;;;;;;;;;;;;;;;;;;;;;;; timeout check ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun timeout-check-monitor-string (monitor)
  (with-slots (timeout last timeout name) monitor

    (if (and monitor   ; monitor not null
             (alive-monitor-p monitor)   ; not stop or suspend
             last                        ; at least one data
             (gethash :update-time last) ; has updata-time
             timeout                     ; timeout is considerd
             (> (- (get-universal-time) (gethash :update-time last)) timeout)) ; past time greater than timeout
        (concatenate 'string name ":TIMEOUT")
        "")))



(defun timeout-check (service)
  "Check whether any of its' monitor not updata for timeout seconds."
  (when service
    (let* ((monitor-list (hash-value-list (service-monitors service)))
           (msg (join-by " " (remove-if #'empty-string (mapcar #'timeout-check-monitor-string monitor-list)))))
      (when (not (empty-string msg))
        (alert-holder service msg :count 2)))))


(defun loop-check-all-service (service-tree)
  (when service-tree
    (maphash (lambda (k v)
               (declare (ignore k))
               (timeout-check v))
             (service-tree-services service-tree))))



; fortest
(defparameter *default-service-tree* (make-service-tree))

(add-monitor-data *default-service-tree* "aa-bb-cc" "m1" (list (cons :status :ok) (cons :time 55)))
(add-monitor-data *default-service-tree* "aa-bb-cc" "m2" (list (cons :status :ok) (cons :time 55)))
(add-monitor-data *default-service-tree* "aa-bb-cc" "m1" (list (cons :status :err) (cons :time 53)))
(add-monitor-data *default-service-tree* "aa-bb-cc" "m3" (list (cons :status :ok) (cons :time 35)))
(add-monitor-data *default-service-tree* "aa-bb-cc" "m1" (list (cons :status :wait) (cons :update-time 55)))
(add-monitor-data *default-service-tree* "aa-bb-cc" "m1" (list (cons :status :ok) (cons :time 55)))

;;;;;;;;;;;;;  for web  ;;;;;;;;;;;;;;;;;;;;;;;
#| |#
(restas:define-module :rest-web)

(in-package :rest-web)

; start

(defclass acceptor (restas:restas-acceptor)
  ()
  (:default-initargs
   :access-log-destination (truename (concatenate 'string (getenv "HOME") "/log/access.log"))
    :message-log-destination (truename (concatenate 'string (getenv "HOME") "/log/message.log"))))


(restas:define-route rest-web::update-monitor-data ("/update-monitor-data/:service/:monitor")
  (monitor::add-monitor-data monitor::*default-service-tree* (string service) (string monitor) (hunchentoot:get-parameters*))
  (format nil "add ok"))


(restas:start :rest-web :port 12345 :acceptor-class 'acceptor)
#| |#
