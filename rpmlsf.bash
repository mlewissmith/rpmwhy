#!/bin/bash
set -u

VERBOSITY=1

function _usage { pod2usage --verbose 0 $0; exit ${1:-0}; }
function _help { pod2usage --verbose 1 $0; exit ${1:-0}; }
function _longhelp { pod2usage --verbose 2 $0; exit ${1:-0}; }
function _version { echo "@PACKAGE_STRING@" ; exit ${1:-0}; }

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
               *) _usage 1 ;;
           esac
           ;;
        *) _usage 1 ;;
    esac
done
shift $((OPTIND - 1))
[[ -z "$@" ]] && _usage


_t=$'\t'
_n=$'\n'
queryformat="[%{fileflags:fflags}${_t}%{filemodes:perms}${_t}%{fileusername}${_t}%{filegroupname}${_t}%{filenames}${_n}]"

for arg in "$@"
do
    p=
    [[ $arg == */* ]] && p=p
    if [[ $VERBOSITY -ge 1 ]]
    then rpm -q$p \
             --nodigest --nosignature \
             --queryformat="${queryformat}" \
             "$arg" | column -s"${_t}" -o' ' -t
    fi
    if [[ $VERBOSITY -ge 2 ]]
    then
        echo
        rpm -q$p "$arg" --provides | column -t -o' '
    fi
done

################################################################################
exit
: <<__DOCEND__

=pod

=head1 NAME

rpmlsf - list contents of rpm packages (long format)

=head1 SYNOPSIS

B<rpmlsf> [I<OPTIONS>] I<PACKAGENAME>|I<FILENAME> ...

B<rpmlsf> B<-h>|B<--help>|B<--man>|B<--version>

=head1 DESCRIPTION

B<rpmlsf>(1) lists the contents of the installed rpm package I<PACKAGENAME> or
the local (s)rpm package file I<FILENAME>.

=head1 OPTIONS

=head2 Verbosity options

=over

=item B<-V1>

Display only I<PACKAGENAME> file contents. B<(default)>

=item B<-V2>

Also display I<PACKAGENAME> provided capabilities.

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

B<rpmwhat>(1),
B<rpmwhy>(1),
B<rpmquerytools>(7),
B<rpm>(8).

=cut

__DOCEND__
