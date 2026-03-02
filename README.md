# rpmquerytools - Tools to query installed package RPMs

## rpmwhy

```
NAME
    rpmwhy - Why is a given package on my system?

SYNOPSIS
    rpmwhy [-v] *PACKAGE*|*FILE*|*CAPABILITY* ...

    rpmwhy -h|-H

DESCRIPTION
    rpmwhy is a wrapper around rpm -q --what{requires,recommends}.

OPTIONS
    -v  Verbose.

    -h  Brief help

    -H  Long help

SEE ALSO
       rpm --test --erase PACKAGE
```
