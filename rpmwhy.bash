#!/usr/bin/bash
set -u

VERBOSITY=1

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

function _usage0 { pod2usage --verbose 0 $0; }
function _usage1 { pod2usage --verbose 1 $0; }
function _usage2 { pod2usage --verbose 2 $0; }
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

while getopts qvhH-: opt
do
    case $opt in
        q) VERBOSITY=0 ;;
        v) ((VERBOSITY++)) ;;
        h) _usage0 ; exit 0 ;;
        -) case $OPTARG in
               help) _usage1 ;;
               man) _usage2 ;;
               version) echo "@PACKAGE_STRING@" ;;
               *) echo "$0: illegal longopt -- $OPTARG" >&2
                  _usage0
                  exit 1
                  ;;
           esac
           exit 0
           ;;
        *) _usage0 ; exit 1 ;;
    esac
done
shift $(($OPTIND - 1))

if [[ -z "$@" ]];
then
    _usage0
    exit 0
fi

for arg in "$@"
do
    _rpmwhy $arg
    for providedby in $(rpmq --whatprovides $arg)
    do
        [[ $? == 0 ]] || break
        [[ $arg == $providedby ]] ||
            vecho "$arg provided-by $providedby"
        for provided in $(QF="[%{PROVIDES}\n]" rpmq $providedby)
        do
            [[ $providedby == $provided ]] ||
               vecho "$providedby provides $provided"
            [[ $provided == $arg ]] ||
                _rpmwhy $provided
        done
    done
done

################################################################################
exit
: <<__DOCEND__

=pod

=head1 NAME

rpmwhy - Why is a given package on my system?

=head1 SYNOPSIS

B<rpmwhy> [OPTION] I<PACKAGE>|I<FILE>|I<CAPABILITY> ...

B<rpmwhy> B<--help>

=head1 DESCRIPTION

B<rpmwhy> is a wrapper around B<rpm -q --what{requires,recommends}>.

=head1 OPTIONS

=head2 General options

=over 4

=item B<-q>

Quiet

=item B<-v>

Verbose

=back

=head2 Information

=over 4

=item B<-h>

Brief help

=item B<--help>

Long help

=item B<--man>

Manpage

=item B<--version>

Display program version

=back

=head1 SEE ALSO

L<< B<@PACKAGE_NAME@>|@PACKAGE_URL@ >>

=cut


__DOCEND__
