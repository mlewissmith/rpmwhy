#!/bin/bash
set -u

s=^

function _usage { pod2usage --verbose 0 $0; exit ${1:-0}; }
function _help { pod2usage --verbose 1 $0; exit ${1:-0}; }
function _longhelp { pod2usage --verbose 2 $0; exit ${1:-0}; }
function _version { echo "@PACKAGE_STRING@" ; exit ${1:-0}; }

while getopts :s:h-: opt
do
    case $opt in
        s) s=$OPTARG ;;
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

for arg in "$@"
do
    p=
    [[ $arg == */* ]] && p=p
    rpm -q$p \
        --queryformat="[%{fileflags:fflags}$s%{filemodes:perms}$s%{fileusername}$s%{filegroupname}$s%{filenames}\n]" \
        --nodigest --nosignature "$arg" | column -s$s -t
done

################################################################################
exit
: <<__DOCEND__

=pod

=head1 NAME

rpmlsf - List contents of rpm packages (long format)

=head1 SYNOPSIS

B<rpmlsf> [I<OPTIONS>] I<PACKAGENAME>|I<FILENAME>...

B<rpmlsf> B<-h>|B<--help>|B<--man>|B<--version>

=head1 DESCRIPTION

B<rpmlsf>(1) lists the contents of the installed I<PACKAGENAME> or the rpm package
file I<FILENAME>

=head1 OPTIONS

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

=head2 Advanced options

=over

=item B<-s> I<CHAR>

Set the internal separator character used to columnate output.

=back


=head1 SEE ALSO

L<< B<@PACKAGE_NAME@>|@PACKAGE_URL@ >>

=cut

__DOCEND__
