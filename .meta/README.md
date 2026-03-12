# @PACKAGE_NAME@

@PACKAGE_SUMMARY@

```
@PACKAGE_DESCRIPTION@
```

## Manifest

### rpmlsf

```
NAME
    rpmlsf - list contents of rpm packages (long format)

SYNOPSIS
    rpmlsf [*OPTIONS*] *PACKAGENAME*|*FILENAME* ...

    rpmlsf -h|--help|--man|--version

DESCRIPTION
    rpmlsf(1) lists the contents of the installed rpm package *PACKAGENAME*
    or the local (s)rpm package file *FILENAME*.

OPTIONS
  Verbosity options
    -V1 Display only *PACKAGENAME* file contents. (default)

    -V2 Also display *PACKAGENAME* provided capabilities.

    -v  Increment verbosity, may be repeated.

    -q  Decrement verbosity, may be repeated.

  Information options
    -h  Brief help.

    --help
        Long help.

    --man
        Manpage.

    --version
        Display program version.

SEE ALSO
    rpmquerytools <https://github.com/mlewissmith/rpmquerytools>.

    rpmwhat(1), rpmwhy(1), rpmquerytools(7), rpm(8).
```

### rpmwhat

```
NAME
    rpmwhat - list dependencies of rpm packages

SYNOPSIS
    rpmwhat [ *OPTIONS* ] *PACKAGENAME* | *FILENAME* | *CAPABILITY* ...

    rpmwhat -h|--help|--man|--version

DESCRIPTION
    rpmwhat(1) lists the package dependencies of a given *PACKAGENAME*, or
    the package dependencies of the package owning a given *FILENAME* or
    *CAPABILITY*.

OPTIONS
  Verbosity options
    -V1 Show packages *PACKAGENAME* "requires".

    -V2 Also show packages *PACKAGENAME* "recommends". [*default*]

    -V3 Also show packages *PACKAGENAME* "suggests".

    -V4 Also show packages "supplemented-by" *PACKAGENAME*. [*experimental*]

    -V5 Also show packages "enhanced-by" *PACKAGENAME*. [*experimental*]

    -v  Increment verbosity, may be repeated.

    -q  Decrement verbosity, may be repeated.

  Colour options
    Output is colourised by default if "STDOUT" is connected to a terminal.

    --[no]colo[u]r
        Control colourised output.

  Information options
    -h  Brief help.

    --help
        Long help.

    --man
        Manpage.

    --version
        Display program version.

ENVIRONMENT
    NO_COLOR
        Disable colour output if set to any value, including "null".

SEE ALSO
    rpmquerytools <https://github.com/mlewissmith/rpmquerytools>.

    rpmlsf(1), rpmwhy(1), rpmquerytools(7), rpm(8).
```

### rpmwhy

```
NAME
    rpmwhy - list dependents of rpm packages

SYNOPSIS
    rpmwhy [ *OPTIONS* ] *PACKAGENAME* | *FILENAME* | *CAPABILITY* ...

    rpmwhy -h | --help | --man | --version

DESCRIPTION
    rpmwhy(1) lists the dependent packages of a given *PACKAGENAME*, or the
    dependent packages of the package owning a given *FILENAME* or
    *CAPABILITY*.

OPTIONS
  Verbosity options
    -V1 Show packages "required-by" *PACKAGENAME*.

    -V2 Also show packages "recommended-by" *PACKAGENAME*. [*default*]

    -V3 Also show packages "suggested-by" *PACKAGENAME*.

    -V4 Also show packages *PACKAGENAME* "supplements". [*experimental*]

    -V5 Also show packages *PACKAGENAME* "enhances". [*experimental*]

    -v  Increment verbosity, may be repeated.

    -q  Decrement verbosity, may be repeated.

  Colour options
    Output is colourised by default if "STDOUT" is connected to a terminal.

    --[no]colo[u]r
        Control colourised output.

  Information options
    -h  Brief help.

    --help
        Long help.

    --man
        Manpage.

    --version
        Display program version.

ENVIRONMENT
    NO_COLOR
        Disable colour output if set to any value, including "null".

SEE ALSO
    rpmquerytools <https://github.com/mlewissmith/rpmquerytools>.

    rpmlsf(1), rpmwhat(1), rpmquerytools(7), rpm(8).
```
