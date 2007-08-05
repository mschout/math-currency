use Test::More tests => 6;

BEGIN { use_ok( Math::Currency ); }

# For subsequent testing, we need to make sure that format is default US
my $format = Math::Currency->format("USD");

my $floating = Math::Currency->new("12.34"); # default to dollars
is ( $floating, '$12.34', 'Individual currency object');
my $dollars = Math::Currency->new("12.34",'USD'); # force to dollars
is ( $dollars, '$12.34', 'Individual currency object');

$format = Math::Currency->format("GBP"); #change default currency
ok ( $format->{INT_CURR_SYMBOL} =~ /GBP/, 'Default currency changed');

is ( $dollars, '$12.34', 'Object did not chang to new default currency');
isnt ( $floating, '$12.34', 'Object changed to new default currency');
