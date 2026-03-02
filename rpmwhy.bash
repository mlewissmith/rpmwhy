#!/usr/bin/bash
set -u

# weak (reverse) dependencies:
# Recommends <=> Supplements
# Suggests <=> Enhances

opt_verbose=true
QF="%{NAME}\n"

function echoerr { echo "$@" >&2; }

function _usage { pod2usage $0; }
function _man { pod2usage --verbose 2 $0; }
function rpmq { rpm --query --queryformat="$QF" --nodigest --nosignature "$@"; }

function _rpmwhy {
    this=$1
    local IFS=$'\n'

    for requiredby in $(rpmq --whatrequires $this)
    do
        [[ $? == 0 ]] || break
        echo "$this required-by $requiredby"
    done

    for recommendedby in $(rpmq --whatrecommends $this)
    do
        [[ $? == 0 ]] || break
        echo "$this recommended-by $recommendedby"
    done

    for supplements in $(QF="[%{SUPPLEMENTS}\n]" rpmq $this)
    do
        [[ $? == 0 ]] || break
        echo "$this supplements $supplements"
    done

    for suggestedby in $(rpmq --whatsuggests $this)
    do
        [[ $? == 0 ]] || break
        echo "$this suggested-by $suggestedby"
    done

    for enhances in $(QF="[%{ENHANCES}\n]" rpmq $this)
    do
        [[ $? == 0 ]] || break
        echo "$this enhances $enhances"
    done
}

while getopts qvhH opt
do
    case $opt in
        q) opt_verbose=false ;;
        v) opt_verbose=true ;;
        h) _usage ; exit 0 ;;
        H) _man ; exit 0 ;;
        *) _usage ; exit 1 ;;
    esac
done
shift $(($OPTIND - 1))

for arg in "$@"
do
    _rpmwhy $arg
    if $opt_verbose
    then
        for providedby in $(rpmq --whatprovides $arg)
        do
            [[ $? == 0 ]] || break
            [[ $arg == $providedby ]] ||
                echo "$arg provided-by $providedby"
            for provided in $(QF="[%{PROVIDES}\n]" rpmq $providedby)
            do
                [[ $providedby == $provided ]] ||
                    echo "$providedby provides $provided"
                [[ $provided == $arg ]] ||
                    _rpmwhy $provided
            done
        done
    fi
done

################################################################################
exit
: <<__DOCEND__

=pod

=head1 NAME

rpmwhy - Why is a given package on my system?

=head1 SYNOPSIS

B<rpmwhy> [B<-q>|B<-v>] I<PACKAGE>|I<FILE>|I<CAPABILITY> ...

B<rpmwhy> B<-h>|B<-H>

=head1 DESCRIPTION

B<rpmwhy> is a wrapper around B<rpm -q --what{requires,recommends}>.

=head1 OPTIONS

=over 4

=item B<-q>

Quiet

=item B<-v>

Verbose

=item B<-h>

Brief help

=item B<-H>

Long help

=back

=head1 SEE ALSO

   rpm --test --erase PACKAGE

=cut


__DOCEND__
