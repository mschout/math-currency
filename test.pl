# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..5\n"; }
END {print "not ok 1\n" unless $loaded;}
use Math::Currency(Money);
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

$dollars = Math::Currency->new('$18123') or print "not";
print "ok 2\n";

$dollars *= 66.33 or print "not ";
$dollars /= 100;
print "ok 3\n";

if ( $dollars < 3500 )
{
	print "not";
}
print "ok 4\n";

unless ( $dollars eq "$12,020.99" )
{
	print "not";
}
print "ok 5\n";

print "\nFormatting tests:\n";

$newdollars = Money(0.10);
print "$newdollars\n";

$newdollars += 12.95;
print "$newdollars\n";

$pounds = Math::Currency->new( -29.95, 
	{
		PREFIX		=>	'',
		SEPARATOR	=>	',',
		DECIMAL		=>	'.',
		POSTFIX		=>	'œ',
		FRAC_DIGITS	=>	2,
		GROUPING	=>	3,
	}
);

print "Now in Pounds Sterling: $pounds\n";
print "$newdollars\n";

$newpounds = $pounds->new(39.95);
print "$newpounds\n";

$newpounds = $newpounds + 100000;
print "$newpounds";
