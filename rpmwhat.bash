#!/usr/bin/bash
set -u

function _usage { pod2usage --verbose 0 $0; exit ${1:-0}; }
function _help { pod2usage --verbose 1 $0; exit ${1:-0}; }
function _longhelp { pod2usage --verbose 2 $0; exit ${1:-0}; }
function _version { echo "@PACKAGE_STRING@" ; exit ${1:-0}; }

function rpmq {
    rpm --query --queryformat=${QF:-'%{NAME}\n'} \
        --nodigest --nosignature "$@"
}

function _rpmwhat {
    this=$1
    local IFS=$'\n'

    # for filename in $(QF='[%{FILENAMES}\n]' rpmq $this)
    # do
    #     echo "$this contains $filename"
    # done

    # for provided in $(QF='[%{PROVIDES}\n]' rpmq $this)
    # do
    #     echo "$this provides $provided"
    # done

    for required in $(QF='[%{REQUIRES}\n]' rpmq $this)
    do
        echo -n "$this requires $required"
        providedby=$(rpmq --whatprovides $required) &&
            echo -n " provided-by $providedby"
        echo
    done

    for recommended in $(QF='[%{RECOMMENDS}\n]' rpmq $this)
    do
        echo -n "$this recommends $recommended"
        providedby=$(rpmq --whatprovides $recommended) &&
            echo -n " provided-by $providedby"
        echo
    done

    for suggested in $(QF='[%{SUGGESTS}\n]' rpmq $this)
    do
        echo -n "$this suggests $suggested"
        providedby=$(rpmq --whatprovides $suggested) &&
            echo -n " provided-by $providedby"
        echo
    done
}

while getopts :h-: opt
do
    case $opt in
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

oIFS="$IFS"
for arg in "$@"
do
    pkg=$(rpmq --whatprovides $arg)
    [[ $? == 0 ]] || continue
    echo "$arg provided-by $pkg"
    _rpmwhat $pkg
done

################################################################################
exit
: <<__DOCEND__

=pod

=head1 NAME

rpmwhat - list dependencies of rpm packages

=head1 SYNOPSIS

B<rpmwhat> [I<OPTIONS>] I<PACKAGENAME>|I<FILENAME>|I<CAPABILITY> ...

B<rpmwhat> B<-h>|B<--help>|B<--man>|B<--version>

=head1 DESCRIPTION

B<rpmwhat>(1) lists the requirements of a given package, and the installed
packages which provide those requirements.

=head1 OPTIONS

=head2 General options

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
B<rpmwhy>(1),
B<rpmquerytools>(7),
B<rpm>(8).

=cut

__DOCEND__
