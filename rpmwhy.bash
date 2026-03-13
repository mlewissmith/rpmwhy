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

function _rpmwhy {
    local capability=$1
    local package=$2
    local this="${cPKG}${package}${c000} provides ${cCAP}${capability}${c000}"
    local IFS=$'\n'

    [[ $VERBOSITY -ge 1 ]] &&
        for requiredby in $(rpmq --whatrequires $capability)
        do
            [[ $? == 0 ]] || break
            echo -e "$this required-by ${cDEP}${requiredby}${c000}"
        done

    [[ $VERBOSITY -ge 2 ]] &&
        for recommendedby in $(rpmq --whatrecommends $capability)
        do
            [[ $? == 0 ]] || break
            echo -e "$this recommended-by ${cDEP}${recommendedby}${c000}"
        done

    [[ $VERBOSITY -ge 3 ]] &&
        for suggestedby in $(rpmq --whatsuggests $capability)
        do
            [[ $? == 0 ]] || break
            echo -e "$this suggested-by ${cDEP}${suggestedby}${c000}"
        done

    # THIS supplements THAT <=> THAT recommends THIS
    # only relevent for packages, not capabilities
    [[ $VERBOSITY -ge 4 && $capability == $package ]] &&
        for supplements in $(QF="[%{SUPPLEMENTS}\n]" rpmq $capability)
        do
            [[ $? == 0 ]] || break
            echo -e "$this supplements ${cDEP}${supplements}${c000}"
        done

    # THIS enhances THAT <=> THAT suggests THIS
    # only relevent for packages, not capabilities
    [[ $VERBOSITY -ge 5 && $capability == $package ]] &&
        for enhances in $(QF="[%{ENHANCES}\n]" rpmq $capability)
        do
            [[ $? == 0 ]] || break
            echo -e "$this enhances ${cDEP}${enhances}${c000}"
        done

    return 0
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

B<rpmwhy> [ I<OPTIONS> ] I<PACKAGENAME> | I<FILENAME> | I<CAPABILITY> ...

B<rpmwhy> B<-h> | B<--help> | B<--man> | B<--version>

=head1 DESCRIPTION

L<rpmwhy(1)> lists the dependent packages of a given I<PACKAGENAME>, or the
dependent packages of the package owning a given I<FILENAME> or I<CAPABILITY>.

=head1 OPTIONS

=head2 Verbosity options

=over

=item B<-V1>

Only display packages C<required-by> I<PACKAGENAME>.

=item B<-V2>

Also display packages C<recommended-by> I<PACKAGENAME>.
B<(default)>

=item B<-V3>

Also display packages C<suggested-by> I<PACKAGENAME>.

=item B<-V4>

Also display packages I<PACKAGENAME> C<supplements>.
I<(experimental)>

=item B<-V5>

Also display packages I<PACKAGENAME> C<enhances>.
I<(experimental)>

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
L<rpmwhat(1)>,
L<rpmquerytools(7)>,
L<rpm(8)>.

=cut

__DOCEND__
