#!perl -w
# $Id: 00_regression_510.t,v 1.2 2008/07/24 18:03:59 drhyde Exp $

use strict;

use Test::More;
plan skip_all => "perl >= 5.10.0 required for mfsortmaker" if($] < 5.010);
plan tests => 2;

use Sort::MultipleFields qw(mfsort mfsortmaker);

my $library = [
    { author => 'Hoyle',  title => 'Black Cloud, The' },
    { author => 'Clarke', title => 'Rendezvous with Rama' },
    { author => 'Clarke', title => 'Prelude to Space' },
    { author => 'Clarke', title => 'Islands In The Sky' },
    { author => 'Asimov', title => 'Pebble in the Sky' },
    { author => 'Asimov', title => 'Foundation' },
    { author => 'Asimov', title => 'David Starr, Space Ranger' }
];

# sort function instead of shortcut
my $usersupplied = mfsortmaker(sub {
    author => sub {
        return -1 if($_[0] =~ '^C');
        return  1 if($_[1] =~ '^C');
        return  1 if($_[0] =~ '^A');
        return -1 if($_[1] =~ '^A');
        return  0;
    }
});
is_deeply(
    [map { $_->{author} } sort $usersupplied @{$library}],
    [qw(Clarke Clarke Clarke Hoyle Asimov Asimov Asimov)],
    'user-supplied sort function works'
);

my $crazysort = mfsortmaker(sub {
    author => 'asc',
    title => 'asc',
    year => 'desc',
    colour => sub { 
        my @in = map {
            $_ eq 'red'    ? 0 :
            $_ eq 'orange' ? 1 :
            $_ eq 'yellow' ? 2 :
            $_ eq 'green'  ? 3 :
            $_ eq 'blue'   ? 4 :
            $_ eq 'indigo' ? 5 :
                             6
        } @_;
        $in[0] <=> $in[1];
    }
});
my $crazyinput = [
    sort {
        rand() < 0.5 ? -1 : 1
    } map {
        { %{$_}, year => 2001 },
        { %{$_}, year => 2002 },
        { %{$_}, year => 2003 },
    } map {
        my $in = $_;
        map { { %{$in}, colour => $_ } }
            qw(red orange yellow green blue indigo violet)
    } @{$library}
];
my $crazyoutput = [
    map {
        my $in = $_;
        map { { %{$in}, colour => $_ } }
            qw(red orange yellow green blue indigo violet)
    } map {
        { %{$_}, year => 2003 },
        { %{$_}, year => 2002 },
        { %{$_}, year => 2001 },
    } mfsort sub {
        author => 'asc', title => 'asc'
    }, $library
];
is_deeply(
    # sort by author, title, reverse publication date, and colour(!)
    [sort $crazysort @{$crazyinput}],
    $crazyoutput,
    "batshit four-field sort works"
);
