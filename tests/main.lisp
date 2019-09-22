(defpackage ipecho/tests/main
  (:use :cl
        :ipecho
        :rove))
(in-package :ipecho/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :ipecho)' in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
    (ok (= 1 1))))
