# $Id: MultipleFields.pm,v 1.1 2008/07/22 17:04:46 drhyde Exp $

package Palm::MultipleFields;

use strict;
use warnings;

use vars qw($VERSION @EXPORT_OK);

require Exporter;

@EXPORT_OK = qw(mfsort);

$VERSION = '1.0';

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

The mfsort subroutine may be exported if you wish, but is not exported by
default.

Default-export is bad and wrong and people who do it should be spanked.

=head1 SUBROUTINES

=head2 mfsort

    @sorted = mfsort { SORT SPEC } @unsorted;

Takes a sort specification and a list (or list-ref) of references to hashes.
It returns either a list or a list-ref (depending on context).

The sort specification is a block structured thus:

    {
        field1 => 'ascending',            # you can say 'asc' instead
	                                  # also 'descending' or 'desc'
	field2 => sub { $_[1] <=> $_[0] }
	field3 => ['ascending', sub { lc(shift) }]
	...
    }

Yes, it looks like a hash.  But it's not, it's a block, and order matters.
That spec is for a sort first on field1, going up; then for all cases where
field1 is the same, sort on field2, going down and doing numeric comparisons;
then for all cases where
both field1 and field2 are the same, sort on field3, going up, and apply
the transformation to each element before sorting.

More formally, the spec can be considered to be a list of field / spec pairs,
where the field is the name of the field in the input hashes, and the spec can
be either a sort function or a listref of a sort function and a transformation.

For convenience the sort function can be abbreviated to be one of the
following strings:

=over

=item ascending, or asc

Sort ASCIIbetically, ascending

=item descending, or desc

Sort ASCIIbetically, descending

=back

A transformation can be
arbitrarily complex.  So you could, for example, use it to smash all data to
ASCII using Text::Unidecode and sort numeric parts numerically instead of
ASCIIbetically using Sort::Naturally.

Really old versions
of perl might require that you instead pass it as a subroutine reference:

    mfsort sub { ... }, @list

=cut

sub mfsort {
    my $spec = shift;
    $spec = [
}

=head1 BUGS, LIMITATIONS and FEEDBACK

If you find any bugs please report them either using
L<http://rt.cpan.org/> or by email.  Ideally, I would like to receive
sample data and a test file, which fails with the latest version of
the module but will pass when I fix the bug.

=head1 SEE ALSO

FIXME

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
