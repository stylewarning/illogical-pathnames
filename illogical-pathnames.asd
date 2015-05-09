;;;; illogical-pathnames.asd
;;;;
;;;; Copyright (c) 2015 Robert Smith <quad@symbo1ics.com>

(asdf:defsystem #:illogical-pathnames
  :description "Mostly filesystem-position-independent pathnames."
  :author "Robert Smith <quad@symbo1ics.com>"
  :license "BSD 3-clause (See illogical-pathnames.lisp)"
  :version "1.0.1"
  :serial t
  :components ((:static-file "README.txt")
               (:file "illogical-pathnames")))

