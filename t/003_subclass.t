use Test::More tests => 7;

use Math::Currency::EUR;
use_ok( Math::Currency::EUR );

my $object = Math::Currency::EUR->new("1.02");

isa_ok ($object, 'Math::Currency');
isa_ok ($object, 'Math::Currency::EUR');
is ( $object, '¤1,02', 'Extended ASCII currency marker');
$Math::Currency::use_int = 1;
is ( $object, 'EUR 1,02', 'ISO currency marker');

my $dollars = Math::Currency::EUR->new("1.02", 'USD'); #weird but legal
is ( $dollars, 'USD 1.02', 'Individual currency object');

$dollars = Math::Currency->new("12.34"); # default to dollars
is ( $dollars, 'USD 12.34', 'Individual currency object');
