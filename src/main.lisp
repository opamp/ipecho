(defpackage ipecho
  (:use :cl
        :usocket
        :bordeaux-threads)
  (:export :get-host-by-name
           :start-server
           :access))
(in-package :ipecho)

;; SBCL only
(defun get-host-by-name (name)
  (declare (type string name))
  (or #+sbcl (multiple-value-bind (v4 v6)
                 (sb-bsd-sockets:get-host-by-name name)
               `(:v4 ,(sb-bsd-sockets:host-ent-address v4)
                 :v6 ,(sb-bsd-sockets:host-ent-address v6)))
      ;#+ccl `(:v4 nil :v6 nil)
      ))

(defun response-to-client (conn &optional silent)
  (let ((client-addr (get-peer-address conn)))
    (unwind-protect
         (progn
           (unless silent
             (format t "[access] ~A~%" client-addr))
           (if (= (length client-addr) 4)
               (format (socket-stream conn) "~{~A~^.~}" (coerce client-addr 'list))
               (format (socket-stream conn) "~{~x~x~^:~}" (coerce client-addr 'list)))
           (force-output (socket-stream conn)))
      (progn
        (socket-close conn)
        (unless silent
          (format t "[closed]~%"))))))

(defun start-server (&key (host "127.0.0.1") (port 9000) silent)
  (let ((threads)
        (socket (socket-listen host port)))
    (handler-case
        (unwind-protect
             (loop
                (let ((conn (socket-accept socket :element-type 'character)))
                  (setf threads (remove-if (lambda (x) (not (thread-alive-p x))) threads))
                  (push (make-thread (lambda () (response-to-client conn silent))) threads)))
          (progn
            (socket-close socket)))
      (condition (c)
        (mapcar #'join-thread threads)
        (socket-close socket)
        (unless silent
          (format t "~A~%stop~%" c))))))

(defun access (host &key (port 9000))
  (let ((socket (socket-connect host port :element-type 'character)))
    (unwind-protect
         (progn
           (wait-for-input socket)
           (format t "~A~%" (read-line (socket-stream socket))))
      (socket-close socket))))
