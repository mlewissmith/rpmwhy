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

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 OPTIONS

=head1 SEE ALSO

L<< B<@PACKAGE_NAME@>|@PACKAGE_URL@ >>

=cut

__DOCEND__
