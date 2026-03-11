#!/usr/bin/bash
set -u

VERBOSITY=2

################################################################################

function echoerr { >&2 echo "$@"; }
function _usage { pod2usage --verbose 0 $0; exit ${1:-0}; }
function _help { pod2usage --verbose 1 $0; exit ${1:-0}; }
function _longhelp { pod2usage --verbose 2 $0; exit ${1:-0}; }
function _version { echo "@PACKAGE_STRING@"; exit ${1:-0}; }

function _init_colour {
    local incolour=
    if [[ -z ${1+x} ]]
    then
        if [[ -n ${NO_COLOR+x} ]]
        then incolour=false
        elif [[ ! -t 1 ]]
        then incolour=false
        else incolour=true
        fi
    elif [[ $1 -eq 0 ]]
    then incolour=false
    else incolour=true
    fi

    local ANSI_RESET="\e[0m"
    local ANSI_BOLD="\e[1m"
    local ANSI_FAINT="\e[2m"
    local ANSI_ITALIC="\e[3m"
    local ANSI_UNDERLINE="\e[4m"

    local ANSI_BLACK="\e[30m"
    local ANSI_RED="\e[31m"
    local ANSI_GREEN="\e[32m"
    local ANSI_YELLOW="\e[33m"
    local ANSI_BLUE="\e[34m"
    local ANSI_MAGENTA="\e[35m"
    local ANSI_CYAN="\e[36m"
    local ANSI_WHITE="\e[37m"

    local ANSI_BRIGHTBLACK="\e[90m"
    local ANSI_BRIGHTRED="\e[91m"
    local ANSI_BRIGHTGREEN="\e[92m"
    local ANSI_BRIGHTYELLOW="\e[93m"
    local ANSI_BRIGHTBLUE="\e[94m"
    local ANSI_BRIGHTMAGENTA="\e[95m"
    local ANSI_BRIGHTCYAN="\e[96m"
    local ANSI_BRIGHTWHITE="\e[97m"

    if $incolour
    then
        cPKG=${ANSI_BOLD}
        cCAP=${ANSI_FAINT}${ANSI_ITALIC}
        cDEP=${ANSI_BOLD}${ANSI_GREEN}
        c000=${ANSI_RESET}
    else
        cPKG=
        cCAP=
        cDEP=
        c000=
    fi
}

function rpmq { rpm --query --queryformat=${QF:-'%{NAME}\n'} --nodigest --nosignature "$@"; }

function _rpmwhat {
    local package=$1
    local IFS=$'\n'

    [[ $VERBOSITY -ge 1 ]] && for required in $(QF='[%{REQUIRES}\n]' rpmq $package)
    do
        echo -ne "${cPKG}${package}${c000} requires ${cCAP}${required}${c000}"
        providedby=$(rpmq --whatprovides $required) &&
            echo -ne " provided-by ${cDEP}$providedby${c000}"
        echo
    done

    [[ $VERBOSITY -ge 2 ]] && for recommended in $(QF='[%{RECOMMENDS}\n]' rpmq $package)
    do
        echo -ne "${cPKG}${package}${c000} recommends ${cCAP}${recommended}${c000}"
        providedby=$(rpmq --whatprovides $recommended) &&
            echo -ne " provided-by ${cDEP}$providedby${c000}"
        echo
    done

    [[ $VERBOSITY -ge 3 ]] && for suggested in $(QF='[%{SUGGESTS}\n]' rpmq $package)
    do
        echo -ne "${cPKG}${package}${c000} suggests ${cCAP}${suggested}${c000}"
        providedby=$(rpmq --whatprovides $suggested) &&
            echo -ne " provided-by ${cDEP}$providedby${c000}"
        echo
    done

    [[ $VERBOSITY -ge 4 ]] && for supplementedby in $(rpmq --whatsupplements $package)
    do
        [[ $? == 0 ]] || break
        echo -ne "${cPKG}${package}${c000} supplemented-by ${cCAP}${supplementedby}${c000}"
        providedby=$(rpmq --whatprovides $supplementedby) &&
            echo -ne " provided-by ${cDEP}$providedby${c000}"
        echo
    done

    [[ $VERBOSITY -ge 5 ]] && for enhancededby in $(rpmq --whatenhances $package)
    do
        [[ $? == 0 ]] || break
        echo -ne "${cPKG}${package}${c000} enhanced-by ${cCAP}${enhancedby}${c000}"
        providedby=$(rpmq --whatprovides $enhancedby) &&
            echo -ne " provided-by ${cDEP}$providedby${c000}"
        echo
    done
}

################################################################################

_init_colour
while getopts :V:vqh-: opt
do
    case $opt in
        V) VERBOSITY=$OPTARG ;;
        v) (( VERBOSITY++ )) ;;
        q) (( VERBOSITY-- )) ;;
        h) _usage ;;
        -) case $OPTARG in
               help) _help ;;
               man) _longhelp ;;
               version) _version ;;
               colour|color) _init_colour 1 ;;
               nocolor|nocolour) _init_colour 0 ;;
               no-color|no-colour) _init_colour 0 ;;
               *) _usage 1 ;;
           esac
           ;;
        *) _usage 1 ;;
    esac
done
shift $(($OPTIND - 1))
[[ -z "$@" ]] && _usage


for arg in "$@"
do
    IFS=$'\n'
    pkg=$(rpmq --whatprovides $arg)
    [[ $? != 0 ]] && echoerr "$pkg" && continue
    [[ $pkg == $arg ]] || echo -e "${cCAP}${arg}${c000} provided-by ${cPKG}${pkg}${c000}"
    _rpmwhat $pkg
done


################################################################################
exit
: <<__DOCEND__

=pod

=head1 NAME

rpmwhat - list dependencies of rpm packages

=head1 SYNOPSIS

B<rpmwhat> [ I<OPTIONS> ] I<PACKAGENAME> | I<FILENAME> | I<CAPABILITY> ...

B<rpmwhat> B<-h>|B<--help>|B<--man>|B<--version>

=head1 DESCRIPTION

L<rpmwhat(1)> lists the package dependencies of a given I<PACKAGENAME>, or the
package dependencies of the package owning a given I<FILENAME> or I<CAPABILITY>.

=head1 OPTIONS

=head2 Verbosity options

=over

=item B<-V1>

Show packages I<PACKAGENAME> C<requires>.

=item B<-V2>

Also show packages I<PACKAGENAME> C<recommends>.
[I<default>]

=item B<-V3>

Also show packages I<PACKAGENAME> C<suggests>.

=item B<-V4>

Also show packages C<supplemented-by> I<PACKAGENAME>.
[I<experimental>]

=item B<-V5>

Also show packages C<enhanced-by> I<PACKAGENAME>.
[I<experimental>]

=item B<-v>

Increment verbosity, may be repeated.

=item B<-q>

Decrement verbosity, may be repeated.

=back

=head2 Colour options

Output is colourised by default if C<STDOUT> is connected to a terminal.

=over

=item B<-->[B<no>]B<colo>[B<u>]B<r>

Control colourised output.

=back

=head2 Information options

=over

=item B<-h>

Brief help.

=item B<--help>

Long help.

=item B<--man>

Manpage.

=item B<--version>

Display program version.

=back

=head1 ENVIRONMENT

=over

=item B<NO_COLOR>

Disable colour output if set to any value, including C<null>.

=back

=head1 SEE ALSO

L<< B<@PACKAGE_NAME@>|@PACKAGE_URL@ >>.

L<rpmlsf(1)>,
L<rpmwhy(1)>,
L<rpmquerytools(7)>,
L<rpm(8)>.

=cut

__DOCEND__
