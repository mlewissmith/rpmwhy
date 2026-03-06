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

for arg in "$@"
do
    _rpmwhat $arg
done

################################################################################
exit
: <<__DOCEND__

=pod

=head1 NAME

rpmwhat - TBD

=head1 SYNOPSIS

B<rpmwhat> [I<OPTION>] I<PACKAGENAME>|I<FILENAME>|I<CAPABILITY> ...

B<rpmwhat> B<-h>|B<--help>|B<--man>|B<--version>

=head1 DESCRIPTION

TBD

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

B<rpmquerytools>(7),
B<rpmlsf>(1),
B<rpmwhat>(1),
B<rpmwhy>(1).

B<rpm>(8).

=cut


__DOCEND__
