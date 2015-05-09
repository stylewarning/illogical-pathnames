                         ILLOGICAL PATHNAMES
                         ===================

                           By Robert Smith


A Situation
-----------

So, you're making a project, but you don't want to hardcode pathnames
everywhere. Maybe because you're not the only user of the program, or
maybe because you're not the only developer, or maybe because your
development and deployment environments are different.

You look in CLHS, and find this wonderful tool called "logical
pathnames", which allow you to specify a "logical host" and
furthermore define a "translation" for this host to a physical
pathname. For example, we might have the logical host "SRC" which
points to the root of our source code, and #P"SRC:assets;my_pic.JPG"
might be a JPEG asset our program uses.

But oops, you forgot, the ANSI standard specifies that logical
pathname namestrings (like the one above) can only contain uppercase
letters, numbers, and hyphens.

So, you go through all of your files and get rid of the underscores
and make everything uppercase.

But oops, you forgot, pathnames get downcased upon translation.

You begin to feel annoyed. Can't we have more logical logical
pathnames?

Illogical pathnames to the rescue. Illogical pathnames are sort of
like logical pathnames that cover the 95% use-case, like the one
above. In general,

    1. Define some illogical hosts---represented as symbols---which
       associate to directories.
    
    Option 2.a. Use the extended #P syntax.
    
    Option 2.b. Make illogical pathnames using MAKE-ILLOGICAL-PATHNAME
                and translate them to physical pathnames using
                TRANSLATE-ILLOGICAL-PATHNAME.

That's it.

You can re-define illogical hosts, store illogical pathnames, etc. The
illogical pathname syntax is transparent and allows you to work with
all of the pathname-expecting functions and macros such as OPEN and
WITH-OPEN-FILE.

Here's an example.

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

What does #P(...) really expand into? Quote it.

    > '#P(:home ("Scratch") "new.txt")
    (ILLOGICAL-PATHNAMES:TRANSLATE-ILLOGICAL-PATHNAME
      #S(ILLOGICAL-PATHNAMES:ILLOGICAL-PATHNAME
          :HOST :HOME
          :DIRECTORY ("Scratch")
          :NAME "new"
          :TYPE "txt"))

Just a translation of an illogical pathname object.

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

Q. Why doesn't #P(...) return an illogical pathname object?

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


Q. What you said about illogical pathnames isn't true. I tried it and
   it works fine!
   
Your implementation (e.g., Clozure CL) sanely nixed Common Lisp's idea
of logical pathnames and made them useful. Unfortunately, it is not
ANSI conforming.


Q. Why didn't you just make a DEFINE-* macro and a function?

Pathnames need to be convenient, and specifying functions in full is
not syntactically convenient. If one doesn't like the #P syntax, they
may opt to create ILLOGICAL-PATHNAME objects and call
TRANSLATE-ILLOGICAL-PATHNAME at will.
