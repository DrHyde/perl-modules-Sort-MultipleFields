# $Id: MultipleFields.pm,v 1.6 2008/07/24 18:03:59 drhyde Exp $

package Sort::MultipleFields;

use strict;
use warnings;

use vars qw($VERSION @EXPORT_OK);

use Scalar::Util qw(reftype);

use Exporter qw(import);
@EXPORT_OK = qw(mfsort mfsortmaker);

$VERSION = '1.0';

my $subcounter = 0;

=head1 NAME

Sort::MultipleFields - Conveniently sort on multiple fields

=head1 SYNOPSIS

    use Sort::MultipleFields qw(mfsort);

    my $library = mfsort {
        author => 'ascending',
        title  => 'ascending'
    } (
        {
            author => 'Hoyle, Fred',
            title  => 'Black Cloud, The'
        },
        {
            author => 'Clarke, Arthur C',
            title  => 'Rendezvous with Rama'
        },
        {
            author => 'Clarke, Arthur C',
            title  => 'Islands In The Sky'
        }
    );

after which C<$library> would be a reference to a list of three hashrefs,
which would be (in order) the data for "Islands In The Sky", "Rendezvous
with Rama", and "The Black Cloud".

=head1 DESCRIPTION

This provides a simple way of sorting structured data with multiple fields.
For instance, you might want to sort a list of books first by author and
within each author sort by title.

=head1 EXPORTS

The subroutines may be exported if you wish, but are not exported by
default.

Default-export is bad and wrong and people who do it should be spanked.

=head1 SUBROUTINES

=head2 mfsort

    @sorted = mfsort { SORT SPEC } @unsorted;

Takes a sort specification and a list (or list-ref) of references to hashes.
It returns either a list or a list-ref, depending on context.

The sort specification is a block structured thus:

    {
        field1 => 'ascending',
        field2 => 'descending',
        field3 => sub {
            lc($_[0]) cmp lc($_[1]) # case-insensitive ascending
        },
        ...
    }

Yes, it looks like a hash.  But it's not, it's a block that returns a
list, and order matters.

The spec is a list of pairs, each consisting of a field to sort on, and
how to sort it.  How to sort is simply a function that, when given a
pair of pieces of data, will return -1, 0 or 1 depending on whether the first
argument is "less than", equal to, or "greater than" the second argument.
Sounds familiar, doesn't it.  As short-cuts for the most common sorts,
the following case-insensitive strings will work:

=over

=item ascending, or asc

Sort ASCIIbetically, ascending (ie C<$a cmp $b>)

=item descending, or desc

Sort ASCIIbetically, descending (ie C<$b cmp $a>)

=item numascending, or numasc

Sort numerically, ascending (ie C<$a <=> $b>)

=item numdescending, or numdesc

Sort numerically, descending (ie C<$b <=> $a>)

=back

Really old versions
of perl might require that you instead pass the sort spec as an
anonymous subroutine.

    mfsort sub { ... }, @list

=cut

sub mfsort(&@) {
    my $spec = shift;
    my @records = @_;
    @records = @{$records[0]} if(reftype($records[0]) eq 'ARRAY');
    (grep { reftype($_) ne 'HASH' } @records) &&
        die(__PACKAGE__."::mfsort: Can only sort hash-refs\n");

    my $sortsub = mfsortmaker($spec, 1);
    @records = sort { $sortsub->($a, $b) } @records;
    return wantarray() ? @records : \@records;
}

=head2 mfsortmaker

This function is only available in perl 5.10.0 and higher.  It is a
fatal error to use it on any earlier version of perl.  The error
message will blame your code cos I don't want the bug reports :-)

This takes a sort spec subroutine reference like C<mfsort> but returns
the name of a
subroutine that you can use with the built-in C<sort>.

    my $sorter = mfsortmaker(sub {
        author => 'asc',
        title  => 'asc'
    });
    @sorted = sort $sorter @unsorted;

=cut

# NB contrary to the above doco, if called with a true second arg it
# returns a subref, to avoid segfaults in 5.8.8

sub mfsortmaker {
    my $spec = shift;
    my $calledfrommfsort = shift;
    die(
        __PACKAGE__."::mfsortmaker: your perl is too old for this function\n".
	'It was called from '.join(' ', (caller(1))[1, 3]).".\n".
	"This is a bug in the calling code\n"
    ) if($] < 5.010 && !$calledfrommfsort);

    die(__PACKAGE__."::mfsortmaker: no sort spec\n") unless(reftype($spec) eq 'CODE');

    my @spec = $spec->();
    my $sortname = __PACKAGE__.'::__generated_'.$subcounter; $subcounter++;

    my $sortsub = sub($$) { 0 }; # default is to not sort at all
    while(@spec) { # eat this from the end towards the beginning
        my($spec, $field) = (pop(@spec), pop(@spec));
        die(__PACKAGE__."::mfsortmaker: malformed spec after $field\n")
            unless(defined($spec));
        if(!ref($spec)) { # got a string
            $spec = ($spec =~ /^asc(ending)?$/i)     ? sub { $_[0] cmp $_[1] } :
                    ($spec =~ /^desc(ending)?$/i)    ? sub { $_[1] cmp $_[0] } :
                    ($spec =~ /^numasc(ending)?$/i)  ? sub { $_[0] <=> $_[1] } :
                    ($spec =~ /^numdesc(ending)?$/i) ? sub { $_[1] <=> $_[0] } :
                    die(__PACKAGE__."::mfsortmaker: Unknown shortcut '$spec'\n");
        }
        my $oldsortsub = $sortsub;
        $sortsub = sub($$) {
            $spec->($_[0]->{$field}, $_[1]->{$field}) ||
            $oldsortsub->($_[0], $_[1])
        }
    }
    if($calledfrommfsort) {
        return $sortsub;
    } else {
        {
            no strict 'refs';
            *{$sortname} = \&{$sortsub};
        }
        return $sortname;
    }
}

=head1 BUGS, LIMITATIONS and FEEDBACK

If you find undocumented bugs please report them either using
L<http://rt.cpan.org/> or by email.  Ideally, I would like to receive
sample data and a test file, which fails with the latest version of
the module but will pass when I fix the bug.

C<mfsortmaker> is not available on perls below version 5.10.0.  That's
because it makes perl segfault.  I think that's a bug in perl.  But if
you can come up with a fix, I would be *most* grateful.  If you do,
please submit it via RT or email as above.

=cut

# =head1 SEE ALSO
# 
# FIXME

=head1 AUTHOR, COPYRIGHT and LICENCE

Copyright 2008 David Cantrell E<lt>david@cantrell.org.ukE<gt>

This software is free-as-in-speech software, and may be used,
distributed, and modified under the terms of either the GNU
General Public Licence version 2 or the Artistic Licence. It's
up to you which one you use. The full text of the licences can
be found in the files GPL2.txt and ARTISTIC.txt, respectively.

=head1 CONSPIRACY

This module is also free-as-in-mason software.

=cut

1;
