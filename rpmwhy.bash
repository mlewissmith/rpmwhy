#!/usr/bin/bash
set -u

VERBOSITY=1
LOOKUP=true
LOOKDOWN=true

ANSI_RESET="\e[0m"
ANSI_BOLD="\e[1m"
ANSI_FAINT="\e[2m"
ANSI_ITALIC="\e[3m"
ANSI_UNDERLINE="\e[4m"

ANSI_BLACK="\e[30m"
ANSI_RED="\e[31m"
ANSI_GREEN="\e[32m"
ANSI_YELLOW="\e[33m"
ANSI_BLUE="\e[34m"
ANSI_MAGENTA="\e[35m"
ANSI_CYAN="\e[36m"
ANSI_WHITE="\e[37m"

ANSI_BRIGHTBLACK="\e[90m"
ANSI_BRIGHTRED="\e[91m"
ANSI_BRIGHTGREEN="\e[92m"
ANSI_BRIGHTYELLOW="\e[93m"
ANSI_BRIGHTBLUE="\e[94m"
ANSI_BRIGHTMAGENTA="\e[95m"
ANSI_BRIGHTCYAN="\e[96m"
ANSI_BRIGHTWHITE="\e[97m"

EMPH=${ANSI_BOLD}${ANSI_GREEN}

function _usage { pod2usage --verbose 0 $0; exit ${1:-0}; }
function _help { pod2usage --verbose 1 $0; exit ${1:-0}; }
function _longhelp { pod2usage --verbose 2 $0; exit ${1:-0}; }
function _version { echo "@PACKAGE_STRING@" ; exit ${1:-0}; }

function vecho { [[ $VERBOSITY -ge 1 ]] && echo "$@"; }

function rpmq { rpm --query --queryformat=${QF:-'%{NAME}\n'} --nodigest --nosignature "$@"; }

function _rpmwhy {
    this=$1
    local IFS=$'\n'

    for requiredby in $(rpmq --whatrequires $this)
    do
        [[ $? == 0 ]] || break
        echo -e "$this required-by ${EMPH}${requiredby}${ANSI_RESET}"
    done

    for recommendedby in $(rpmq --whatrecommends $this)
    do
        [[ $? == 0 ]] || break
        echo -e "$this recommended-by ${EMPH}${recommendedby}${ANSI_RESET}"
    done

    for suggestedby in $(rpmq --whatsuggests $this)
    do
        [[ $? == 0 ]] || break
        echo -e "$this suggested-by ${EMPH}${suggestedby}${ANSI_RESET}"
    done

    # supplements <=> reverse recommends
    # for supplements in $(QF="[%{SUPPLEMENTS}\n]" rpmq $this)
    # do
    #     [[ $? == 0 ]] || break
    #     echo -e "$this supplements ${EMPH}${supplements}${ANSI_RESET}"
    # done

    # enhances <=> reverse suggests
    # for enhances in $(QF="[%{ENHANCES}\n]" rpmq $this)
    # do
    #     [[ $? == 0 ]] || break
    #     echo -e "$this enhances ${EMPH}${enhances}${ANSI_RESET}"
    # done
}

while getopts :PCqh-: opt
do
    case $opt in
        P) LOOKUP=false ;;
        C) LOOKDOWN=false ;;
        q) VERBOSITY=0 ;;
        h) _usage ;;
        -) case $OPTARG in
               help) _help ;;
               man) _longhelp ;;
               version) _version ;;
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
    _rpmwhy $arg

    $LOOKUP && for providedby in $(rpmq --whatprovides $arg)
    do
        [[ $? == 0 ]] || break
        if [[ $providedby != $arg ]]
        then
            vecho "$arg provided-by $providedby"
            _rpmwhy $providedby
        fi

        $LOOKDOWN && for provided in $(QF="[%{PROVIDES}\n]" rpmq $providedby)
        do
            [[ $provided == $arg ]] && continue
            [[ $provided == $providedby ]] && continue
            vecho "$providedby provides $provided"
            _rpmwhy $provided
        done
    done
done

################################################################################
exit
: <<__DOCEND__

=pod

=head1 NAME

rpmwhy - list dependents of rpm packages

=head1 SYNOPSIS

B<rpmwhy> [I<OPTIONS>] I<PACKAGENAME>|I<FILENAME>|I<CAPABILITY> ...

B<rpmwhy> B<-h>|B<--help>|B<--man>|B<--version>

=head1 DESCRIPTION

B<rpmwhy>(1) shows why a given I<PACKAGENAME>, I<FILENAME> or package
I<CAPABILITY> is installed on the system.

=over

=item *

Which packages require/recommend/suggest the command-line arguments

=item *

Which packages require/recommend/suggest the parent package owning the
command-line arguments.  Option B<-P> suppresses this.

=item *

Which packages require/recommend/suggest the capabilities provided by the
package owning the command-line arguments.  Option B<-C> suppresses this.

=back

=head1 OPTIONS

=head2 General options

=over

=item B<-P>

Suppress details for providing parent package.

=item B<-C>

Suppress details for child capabilities of parent package.

=item B<-q>

Suppress program progress output.

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

=head1 BUGS

B<rpmwhy>(1) calls B<rpm -q> under the hood, potentially I<many> times.
Therefore it can be slow.

=head1 SEE ALSO

L<< B<@PACKAGE_NAME@>|@PACKAGE_URL@ >>.

B<rpmlsf>(1),
B<rpmwhat>(1),
B<rpmquerytools>(7),
B<rpm>(8).

=cut

__DOCEND__
