;;;; illogical-pathnames.asd
;;;;
;;;; Copyright (c) 2015 Robert Smith <quad@symbo1ics.com>

(asdf:defsystem #:illogical-pathnames
  :description "A slightly more logical logical pathname."
  :author "Robert Smith <quad@symbo1ics.com>"
  :license "BSD 3-clause (See illogical-pathnames.lisp)"
  :version "1.0.0"
  :serial t
  :components ((:static-file "README.txt")
               (:file "illogical-pathnames")))

