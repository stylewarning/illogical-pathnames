                         ILLOGICAL PATHNAMES
                         ===================

                           By Robert Smith


Purpose
-------

The purpose of this library is to allow one to specify pathnames in
source files whose syntax mostly doesn't depend on a physical path
location. To put it simply, one can write

    #P(:HOME (".emacs.d") "foo.el")

instead of

    #P"/home/me/.emacs.d/foo.el".

Somewhere, :HOME---a so-called "illogical host"---has to be
specified. This is done by associating it with a directory via the
macro DEFINE-ILLOGICAL-HOST. They can be redefined, which won't affect
evaluated uses of #P(...) syntax.

The former syntax isn't actually an "illogical pathname"; it evaluates
to a physical pathname. (See the example below and the FAQ.) However,
it does involve objects of the type ILLOGICAL-PATHNAME under the hood.

Using illogical pathnames allows one to easily write code whose
pathnames are relative to a few known base directories. When the
program is moved, or perhaps an executable is created, one only has to
redefine the set of illogical hosts. Using the power of
*LOAD-TRUENAME* and others, one can make mostly portable applications
that don't depend on physical filesystem location at all.


Name
----

Before this library, I attempted to solve the same problem by defining
logical hosts with wildcard translations. This worked relatively well
with Clozure CL, due to their more flexible implementation of logical
pathnames. However, more ANSI compliant systems (with respect to
logical pathnames) didn't work with the same code. As such, in my
mind, I made "logical pathnames that solve the 95% case" and called
them "illogical pathnames", a play on the fact that they were supposed
to be "logical logical pathnames". (A double positive makes a
negative, right?)

Despite the name and the reasoning behind the name, these aren't a
replacement for logical pathnames and are not "better" than logical
pathnames; they just solve a different problem than that which logical
hosts solve on modern machines..


Example
-------

Note that normal pathname syntax isn't changed.

    > #P"/foo/bar"
    #P"/foo/bar"

Let's define an illogical host that points to my home directory.

    > (ipath:define-illogical-host :home "/home/me/")
    :HOME

Let's use the extended pathname syntax to refer to a file in my home
directory.

    > #P(:home ("Scratch") "new.txt")
    #P"/home/me/Scratch/new.txt"

We see that #P(...) isn't truly a literal for an illogical
pathname. It returned a physical pathname. What does #P(...) really
expand into then?

    > '#P(:home ("Scratch") "new.txt")
    (ILLOGICAL-PATHNAMES:TRANSLATE-ILLOGICAL-PATHNAME
      #S(ILLOGICAL-PATHNAMES:ILLOGICAL-PATHNAME
          :HOST :HOME
          :DIRECTORY ("Scratch")
          :NAME "new"
          :TYPE "txt"))

Just an unevaluated translation of an illogical pathname object.

Let's define another illogical host referring to my scratch space
directory in my home directory.

    > (ipath:define-illogical-host :scratch #P(:home ("Scratch")))
    :SCRATCH

Let's open a new file and write to it in my scratch space.

    > (with-open-file (s #P(:scratch nil "test.txt") :direction ':output
                                                     :if-does-not-exist ':create)
        (write-string "testing, 1 2 3" s))
    "testing, 1 2 3"

And finally, let's read it back.

    > (with-open-file (s #P(:scratch nil "test.txt") :direction ':input)
        (read-line s))
    "testing, 1 2 3"
     T

That is basically it.


Frequently Asked Questions
--------------------------

Q. Why doesn't #P(...) specify a literal illogical pathname object?

This was a pragmatic choice. If Common Lisp had a generic function
called, say, TRANSLATE-TO-PATHNAME which all relevant Common Lisp
functions knew about, we could indeed use illogical pathname objects
by creating a method of that generic function. However, since we don't
have that functionality, yet we want to relatively transparently be
able to specify illogical pathnames in the places they're used, we do
the translation within the expansion of #P(...).


Q. My system needs to be bootstrapped, and I can't rely on Quicklisp
   or ASDF, but I want to use illogical pathnames.

No problem. The file "illogical-pathnames.lisp" is self-contained. You
can load it as-is.


Q. Logical pathnames can solve this problem. I tried it and
   it works fine!
   
Your implementation (e.g., Clozure CL) sanely nixed Common Lisp's idea
of logical pathnames and made them more useful for solving this
problem. Unfortunately, it is not ANSI conforming.


Q. Why didn't you just make a DEFINE-* macro and a function?

Pathnames need to be convenient, and specifying functions in full is
not syntactically convenient. If one doesn't like the #P syntax, they
may opt to create ILLOGICAL-PATHNAME objects and call
TRANSLATE-ILLOGICAL-PATHNAME at will.

       > (ipath:define-illogical-host :home "/Users/me/")
       :HOME
       > (ipath:make-illogical-pathname
          :host ':home
          :directory '("foo" "bar")
          :name "test"
          :type "txt")
       #S(ILLOGICAL-PATHNAMES:ILLOGICAL-PATHNAME :HOST :HOME :DIRECTORY ("foo" "bar") :NAME "test" :TYPE "txt")
       > (ipath:translate-illogical-pathname *)
       #P"/Users/me/foo/bar/test.txt"
