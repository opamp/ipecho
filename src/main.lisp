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

(defun response-to-client (conn)
  (let ((client-addr (get-peer-address conn)))
    (unwind-protect
         (progn
           (format (socket-stream conn) "~A" client-addr)
           (force-output (socket-stream conn)))
      (progn
        (format t "socket closed~%")
        (socket-close conn)))))

(defun start-server (&key (host "127.0.0.1") (port 9000))
  (let ((threads)
        (socket (socket-listen host port)))
    (handler-case
        (unwind-protect (loop
                           (let ((conn (socket-accept socket :element-type 'character)))
                             (push (make-thread (lambda () (response-to-client conn))) threads)))
          (progn
            (mapcar #'join-thread threads)
            (socket-close socket)))
      (condition (c)
        (mapcar #'join-thread threads)
        (socket-close socket)
        (format t "stop~%")))))

(defun access (host &key (port 9000))
  (let ((socket (socket-connect host port :element-type 'character)))
    (unwind-protect
         (progn
           (wait-for-input socket)
           (format t "~A~%" (read-line (socket-stream socket))))
      (socket-close socket))))
