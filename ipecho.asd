(defsystem "ipecho"
  :version "0.1.0"
  :author "Masahiro NAGATA"
  :license "MIT"
  :depends-on ()
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description ""
  :in-order-to ((test-op (test-op "ipecho/tests"))))

(defsystem "ipecho/tests"
  :author "Masahiro NAGATA"
  :license "MIT"
  :depends-on ("ipecho"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for ipecho"
  :perform (test-op (op c) (symbol-call :rove :run c)))
