use Test::More tests => 10;

BEGIN { use_ok( Math::Currency::ja_JP ); }

# For subsequent testing, we need to make sure that format is default US
Math::Currency->format('USD');

my $object = Math::Currency::ja_JP->new("102");

isa_ok ($object, 'Math::Currency');
isa_ok ($object, 'Math::Currency::ja_JP');
is ( $object, 'бя102', 'Extended ASCII currency marker');
$Math::Currency::use_int = 1;
is ( $object, 'JPY 102', 'ISO currency marker');

my $dollars = Math::Currency::JPY->new("1.02", 'USD'); #weird but legal
is ( $dollars, 'USD 1.02', 'Individual currency object');

$dollars = Math::Currency->new("12.34"); # default to dollars
is ( $dollars, 'USD 12.34', 'Individual currency object');

$Math::Currency::use_int = 0;
my $yen = Math::Currency::ja_JP->new(-2995.95);
is ( $yen, 'бя-2,996', "foreign currency with auto-rounding" );
my $newyen = $yen->new(-2996);
ok ( $yen == $newyen, "two object equality (numeric)" );
ok ( $yen eq $newyen, "two object equality (string)" );

