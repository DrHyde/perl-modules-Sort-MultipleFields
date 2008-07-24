#!perl -w
# $Id: 00_regression_58.t,v 1.1 2008/07/24 17:44:22 drhyde Exp $

use strict;

use Test::More;
plan skip_all => "perl < 5.10.0 required for this test" if($] >= 5.010);
plan tests => 1;

use Sort::MultipleFields qw(mfsortmaker);

my $crazysort = sub { };
eval "mfsortmaker(sub {})";
ok($@, "mfsortmaker dies on perl < 5.10.0");
