#!/usr/bin/bash
set -u

VERBOSITY=2
DEBUG=false

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

cPKG=${ANSI_BOLD}
cCAP=${ANSI_FAINT}${ANSI_ITALIC}
cDEP=${ANSI_BOLD}${ANSI_GREEN}
c000=${ANSI_RESET}

################################################################################

function echoerr { >&2 echo "$@"; }
function _usage { pod2usage --verbose 0 $0; exit ${1:-0}; }
function _help { pod2usage --verbose 1 $0; exit ${1:-0}; }
function _longhelp { pod2usage --verbose 2 $0; exit ${1:-0}; }
function _version { echo "@PACKAGE_STRING@"; exit ${1:-0}; }

function rpmq { rpm --query --queryformat=${QF:-'%{NAME}\n'} --nodigest --nosignature "$@"; }

function _rpmwhy {
    local capability=$1
    local package=$2
    local this="${cPKG}${package}${c000} provides ${cCAP}${capability}${c000}"
    local IFS=$'\n'

    [[ $VERBOSITY -gt 0 ]] &&
        for requiredby in $(rpmq --whatrequires $capability)
        do
            [[ $? == 0 ]] || break
            echo -e "$this required-by ${cDEP}${requiredby}${c000}"
        done

    [[ $VERBOSITY -gt 1 ]] &&
        for recommendedby in $(rpmq --whatrecommends $capability)
        do
            [[ $? == 0 ]] || break
            echo -e "$this recommended-by ${cDEP}${recommendedby}${c000}"
        done

    [[ $VERBOSITY -gt 2 ]] &&
        for suggestedby in $(rpmq --whatsuggests $capability)
        do
            [[ $? == 0 ]] || break
            echo -e "$this suggested-by ${cDEP}${suggestedby}${c000}"
        done

    # supplements <=> reverse recommends
    [[ $VERBOSITY -gt 3 ]] &&
        for supplements in $(QF="[%{SUPPLEMENTS}\n]" rpmq $capability)
        do
            [[ $? == 0 ]] || break
            echo -e "$this supplements ${cDEP}${supplements}${c000}"
        done

    # enhances <=> reverse suggests
    [[ $VERBOSITY -gt 4 ]] &&
        for enhances in $(QF="[%{ENHANCES}\n]" rpmq $capability)
        do
            [[ $? == 0 ]] || break
            echo -e "$this enhances ${cDEP}${enhances}${c000}"
        done

    return 0
}

################################################################################

while getopts :V:vqDh-: opt
do
    case $opt in
        V) VERBOSITY=$OPTARG ;;
        v) (( VERBOSITY++ )) ;;
        q) (( VERBOSITY-- )) ;;
        D) DEBUG=true ;;
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
    IFS=$'\n'
    for providedby in $(rpmq --whatprovides $arg)
    do
        [[ $? != 0 ]] && echoerr "$providedby" && break;

        this="${cCAP}${arg}${c000}"
        that="${cPKG}${providedby}${c000}"
        [[ $arg == $providedby ]] ||
            echo -e "$this provided-by $that"

        _rpmwhy $arg $providedby

        [[ $arg == $providedby ]] ||
            _rpmwhy $providedby $providedby

        for provided in $(QF="[%{PROVIDES}\n]" rpmq $providedby)
        do
            [[ $provided == $arg ]] && continue
            [[ $provided == $providedby ]] ||
                _rpmwhy $provided $providedby
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

B<rpmwhy>(1) lists the dependent packages of a given I<PACKAGENAME>, or the
dependent packages of the package owning a given I<FILENAME> or I<CAPABILITY>.

=head1 OPTIONS

=head2 Verbosity options

=over

=item B<-V> I<NUM>

Set verbosity to I<NUM>.

=over

=item B<1>

C<required-by>

=item B<2>

C<recommended-by> [B<default>]

=item B<3>

C<suggested-by>

=item B<4>

C<supplements> [I<experimental>]

=item B<5>

C<enhances> [I<experimental>]

=back

=item B<-v>

Increment verbosity, may be repeated.

=item B<-q>

Decrement verbosity, may be repeated.

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

=head1 SEE ALSO

L<< B<@PACKAGE_NAME@>|@PACKAGE_URL@ >>.

B<rpmlsf>(1),
B<rpmwhat>(1),
B<rpmquerytools>(7),
B<rpm>(8).

=cut

__DOCEND__
