#!/bin/perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

use Test::More tests => 25;

use Math::Currency(Money);
use_ok( Math::Currency );

# check that the minimal format defaults got set up

ok ( $Math::Currency::CLASSDATA, "format defaults configured" );

foreach $param qw( PREFIX POSTFIX SEPARATOR DECIMAL FRAC_DIGITS GROUPING )
{
	ok ( defined $Math::Currency::CLASSDATA->{$param}, "$param parameter exists: ".$Math::Currency::CLASSDATA->{$param} )
}

# For subsequent testing, we need to make sure that format is default US
Math::Currency->format(
	{
		PREFIX 		=>	'$',
		POSTFIX		=>	'',
		SEPARATOR	=>	',',
		DECIMAL		=>	'.',
		FRAC_DIGITS 	=>	'2',
		GROUPING	=>	'3',
	}
);

ok ( $dollars = Math::Currency->new('$18123'), "class new" );
ok ( $dollars = $dollars->new('$18123'), "object new" );
ok ( $newdollars = Money(0.10), "new via exported Money()");

is ( $dollars *= 66.33, '$1,202,098.59', "multiply");
is ( $dollars /= 100, '$12,020.99', "divide");

ok ( $dollars > 3500, "greater than (numeric)" );
ok ( $dollars < 13500, "less than (numeric)" );
ok ( $dollars == 12020.99, "equal to (numeric)" );
ok ( $dollars eq '$12,020.99', "equal to (string)" );

$dollars = Math::Currency->new(-42);
is ( $dollars,'($42)', "display of negative currency" );

$dollars = Math::Currency->new(56);

ok ( $dollars * 0.555 == 31.08, "multiply followed by auto-round" );

$dollars = Math::Currency->new(20.01);

ok ( $dollars * 1.0 == 20.01, "identity multiply");

$newdollars = $dollars * -1.0;

ok (  $newdollars == -20.01, "negative identity multiply" );

$deutchmarks = Math::Currency->new( -29.95,
	{
		PREFIX		=>	'',
		SEPARATOR	=>	' ',
		DECIMAL		=>	',',
		POSTFIX		=>	'DM',
		FRAC_DIGITS	=>	3,
		GROUPING	=>	3,
	}
);
ok ( $deutchmarks eq '(29,950DM)', "foreign currency" );
$newdm = $deutchmarks->new(-29.95);
ok ( $deutchmarks == $newdm, "two object equality (numeric)" );
ok ( $deutchmarks eq $newdm, "two object equality (string)" );

$pounds = Math::Currency->new( 98994.95,
	{
		PREFIX		=>	'',
		SEPARATOR	=>	',',
		DECIMAL		=>	'.',
		POSTFIX		=>	'£',
		FRAC_DIGITS	=>	2,
		GROUPING	=>	3,
	}
);

$newpounds = $pounds + 100000;

is ( ref($newpounds), ref($pounds), "autoupgrade to object" );

print "\n# Formatting examples:\n";
print "# In Pounds Sterling:	$pounds\n";
print "# In negative Dollars:	$newdollars\n";

$deutchmarks = Math::Currency->new( 23459.95,
	{
		PREFIX		=>	'',
		SEPARATOR	=>	' ',
		DECIMAL		=>	',',
		POSTFIX		=>	'DM',
		FRAC_DIGITS	=>	3,
		GROUPING	=>	3,
	}
);

print "# In Deutchmarks: 	$deutchmarks\n";
