#!/usr/bin/bash
set -u

# weak (reverse) dependencies:
# Recommends <=> Supplements
# Suggests <=> Enhances

opt_verbose=false

function _usage { pod2usage $0; }
function _man { pod2usage --verbose 2 $0; }
function rpmq { rpm --query --nodigest --nosignature "$@"; }
function nevra2name { rpmq --queryformat "%{NAME}" $1; }

function echoerr { echo "$@" >&2; }

function _rpmwhy {
    this=$1
    local IFS=$'\n'

    for requiredby in $(rpmq --whatrequires $this)
    do
        [[ $? == 0 ]] || break
        that=$(nevra2name $requiredby)
        echo "$this required-by $that"
    done

    for recommendedby in $(rpmq --whatrecommends $this)
    do
        [[ $? == 0 ]] || break
        that=$(nevra2name $recommendedby)
        echo "$this recommended-by $that"
    done

    for supplements in $(rpmq $this --supplements)
    do
        [[ $? == 0 ]] || break
        echo "$this supplements $supplements"
    done

    for suggestedby in $(rpmq --whatsuggests $this)
    do
        [[ $? == 0 ]] || break
        that=$(nevra2name $suggestedby)
        echo "$this suggested-by $that"
    done

    for enhances in $(rpmq $this --enhances)
    do
        [[ $? == 0 ]] || break
        echo "$this enhances $enhances"
    done
}

while getopts qvhH opt
do
    case $opt in
        v) opt_verbose=true ;;
        h) _usage ; exit 0 ;;
        H) _man ; exit 0 ;;
        *) _usage ; exit 1 ;;
    esac
done
shift $(($OPTIND - 1))

for arg in "$@"
do
    for providedby in $(rpmq --whatprovides $arg)
    do
        [[ $? == 0 ]] || break
        rpmname=$(nevra2name $providedby)
        [[ $rpmname == $arg ]] || echo "$arg provided-by $rpmname"
        if $opt_verbose
        then
            for provided in $(rpmq $rpmname --queryformat "[%{PROVIDES}\n]")
            do
                [[ $provided == $arg ]] || echo "$arg provides $provided"
                _rpmwhy $provided
            done
        else
            _rpmwhy $arg
        fi
    done

    for obsoleted in $(rpmq $arg --queryformat "[%{OBSOLETES}\n]")
    do
        [[ $? == 0 ]] || break
        echo "$arg obsoletes $obsoleted"
        _rpmwhy $obsoleted
    done
done

################################################################################
exit
: <<__DOCEND__

=pod

=head1 NAME

rpmwhy - Why is a given package on my system?

=head1 SYNOPSIS

B<rpmwhy> [B<-v>] I<PACKAGE>|I<FILE>|I<CAPABILITY> ...

B<rpmwhy> B<-h>|B<-H>

=head1 DESCRIPTION

B<rpmwhy> is a wrapper around B<rpm -q --what{requires,recommends}>.

=head1 OPTIONS

=over 4

=item B<-v>

Verbose.

=item B<-h>

Brief help

=item B<-H>

Long help

=back

=head1 SEE ALSO

   rpm --test --erase PACKAGE

=cut


__DOCEND__
