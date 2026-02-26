#!/usr/bin/bash
set -u

# weak (reverse) dependencies:
# Recommends <=> Supplements
# Suggests <=> Enhances

whatprovidesthis=false
whatrequiresthis=true
whatrecommendsthis=true
whatsuggeststhis=true
thissupplementswhat=true
thisenhanceswhat=true
thisobsoleteswhat=true

files=
fileowners=

function _usage { pod2usage $0; }
function _man { pod2usage --verbose 2 $0; }
function nevra2name { rpm -q --qf "%{NAME}" $1; }

while getopts pf:hm opt
do
    case $opt in
        p) whatprovidesthis=true ;;
        f) whatprovidesthis=true
           files+="${OPTARG} " ;;
        h) _usage ; exit 0 ;;
        m) _man ; exit 0 ;;
        *) _usage ; exit 1 ;;
    esac
done
shift $(($OPTIND - 1))

if [[ -n $files ]]
then
    for f in $files
    do
        fileowners+="$(rpm -q --qf '%{NAME}\n' -f $f)"
    done
fi

for capability in $files $fileowners $@
do
    $thisobsoleteswhat && for obsoletes in $(rpm -q $capability --qf "%{OBSOLETES}\n")
    do
        [[ $? == 0 ]] || break
        [[ $obsoletes == "(none)" ]] && break
        echo "$capability obsoletes $obsoletes"
    done

    $whatprovidesthis && for providedby in $(rpm -q --whatprovides $capability)
    do
        [[ $? == 0 ]] || break
        rpmname=$(nevra2name $providedby)
        [[ $rpmname == $capability ]] && break
        echo "$capability provided-by $rpmname"
    done

    $whatrequiresthis && for requiredby in $(rpm -q --whatrequires $capability)
    do
        [[ $? == 0 ]] || break
        rpmname=$(nevra2name $requiredby)
        [[ $rpmname == $capability ]] && break
        echo "$capability required-by $rpmname"
    done

    $whatrecommendsthis && for recommendedby in $(rpm -q --whatrecommends $capability)
    do
        [[ $? == 0 ]] || break
        rpmname=$(nevra2name $recommendedby)
        [[ $rpmname == $capability ]] && break
        echo "$capability recommended-by $rpmname"
    done

    $whatsuggeststhis && for suggestedby in $(rpm -q --whatsuggests $capability)
    do
        [[ $? == 0 ]] || break
        rpmname=$(nevra2name $suggestedby)
        [[ $rpmname == $capability ]] && break
        echo "$capability suggested-by $rpmname"
    done

    ## RPM WEAK REVERSE DEPENDENCIES
    (
        IFS=$'\n'
        $thissupplementswhat && for supplements in $(rpm -q --supplements $capability)
        do
            [[ $? == 0 ]] || break
            echo "$capability supplements $supplements"
        done

        $thisenhanceswhat && for enhances in $(rpm -q --enhances $capability)
        do
            [[ $? == 0 ]] || break
            echo "$capability enhances $enhances"
        done
    )
done

################################################################################
: <<__DOCEND__

=pod

=head1 NAME

rpmwhy - Query all packages that require/recommend CAPABILITY

=head1 SYNOPSIS

B<rpmwhy> [ -p ] [ -f I<FILE> ] I<CAPABILITY> ...

=head1 DESCRIPTION

Why is a given package on my system?

B<rpmwhy> is a wrapper around B<rpm -q --what{requires,recommends}>.

=head1 OPTIONS

=over 4

=item B<-p>

Also query packages that B<p>rovide I<CAPABILITY>.
C<rpm -q --whatprovides CAPABILITY>

=item B<-f> I<FILE>

Also query packages that provide I<FILE>.
C<rpm -q --whatprovides -f FILE>

Option may repeated, or multiple I<FILE>s may be joined as a single space-delimited string.
Implies B<-p>

=item B<-h>

Help

=item B<-m>

man page

=back

=head1 EXAMPLES

   $ rpmwhy glibc
   glibc required-by libstdc++
   glibc required-by pam
   glibc required-by lockdev
   glibc required-by glibc-common
   glibc required-by glibc-langpack-en
   glibc required-by glibc-headers
   glibc required-by glibc-devel

   $ rpmwhy -f /usr/bin/xterm
   /usr/bin/xterm provided-by xterm
   xterm provided-by xterm
   xterm required-by clusterssh

   $ rpmwhy -p "libxslt.so.1()(64bit)"
   libxslt.so.1()(64bit) provided-by libxslt
   libxslt.so.1()(64bit) required-by libxslt
   libxslt.so.1()(64bit) required-by raptor2
   libxslt.so.1()(64bit) required-by xmlsec1
   libxslt.so.1()(64bit) required-by xmlsec1-nss
   libxslt.so.1()(64bit) required-by yelp-libs
   libxslt.so.1()(64bit) required-by php-xml
   libxslt.so.1()(64bit) required-by webkit2gtk3
   libxslt.so.1()(64bit) required-by libreoffice-core
   libxslt.so.1()(64bit) required-by python3-lxml


=head1 BUGS

Complicated dependencies confuse B<rpmwhy>.  For example:

   $ rpmwhy.sh glibc-langpack-en
   glibc-langpack-en supplements (glibc
   glibc-langpack-en supplements and
   glibc-langpack-en supplements (langpacks-core-en
   glibc-langpack-en supplements or
   ...

   $ rpm -q --supplements glibc-langpack-en
   (glibc and (langpacks-core-en or ...


=head1 SEE ALSO

   rpm --test --erase PACKAGE


=cut

__DOCEND__
