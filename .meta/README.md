# @PACKAGE_NAME@

@PACKAGE_SUMMARY@

```
@PACKAGE_DESCRIPTION@
```

## Manifest

### rpmwhat

```
NAME
    rpmwhat - list dependencies of rpm packages

SYNOPSIS
    rpmwhat [OPTIONS] PACKAGENAME|FILENAME|CAPABILITY ...

    rpmwhat -h|--help|--man|--version

DESCRIPTION
    TBD

OPTIONS
  General options
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

    rpmlsf(1), rpmwhy(1), rpmquerytools(7), rpm(8).
```

### rpmwhy

```
NAME
    rpmwhy - list dependents of rpm packages

SYNOPSIS
    rpmwhy [OPTIONS] PACKAGENAME|FILENAME|CAPABILITY ...

    rpmwhy -h|--help|--man|--version

DESCRIPTION
    rpmwhy(1) shows why a given PACKAGENAME, FILENAME or package CAPABILITY
    is installed on the system.

    *   Which packages require/recommend/suggest the command-line arguments

    *   Which packages require/recommend/suggest the parent package owning
        the command-line arguments. Option -P suppresses this.

    *   Which packages require/recommend/suggest the capabilities provided
        by the package owning the command-line arguments. Option -C
        suppresses this.

OPTIONS
  General options
    -P  Suppress details for providing parent package.

    -C  Suppress details for child capabilities of parent package.

    -q  Suppress program progress output.

  Information options
    -h  Brief help.

    --help
        Long help.

    --man
        Manpage.

    --version
        Display program version.

BUGS
    rpmwhy(1) calls rpm -q under the hood, potentially many times. Therefore
    it can be slow.

SEE ALSO
    rpmquerytools <https://github.com/mlewissmith/rpmquerytools>.

    rpmlsf(1), rpmwhat(1), rpmquerytools(7), rpm(8).
```

### rpmlsf

```
NAME
    rpmlsf - list contents of rpm packages (long format)

SYNOPSIS
    rpmlsf [OPTIONS] PACKAGENAME|FILENAME ...

    rpmlsf -h|--help|--man|--version

DESCRIPTION
    rpmlsf(1) lists the contents of the installed rpm package PACKAGENAME or
    the rpm package file FILENAME

OPTIONS
  Information options
    -h  Brief help.

    --help
        Long help.

    --man
        Manpage.

    --version
        Display program version.

  Advanced options
    -s CHAR
        Set the internal separator character used to columnate output.

SEE ALSO
    rpmquerytools <https://github.com/mlewissmith/rpmquerytools>.

    rpmwhat(1), rpmwhy(1), rpmquerytools(7), rpm(8).
```
