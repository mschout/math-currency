#!/bin/perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

use Test::More tests => 46;
use Math::Currency qw(Money $LC_MONETARY $FORMAT);
use_ok( Math::Currency );

# check that the minimal format defaults got set up

ok ( defined $Math::Currency::FORMAT, "format defaults configured" );

foreach $param qw( INT_CURR_SYMBOL CURRENCY_SYMBOL MON_DECIMAL_POINT
		   MON_THOUSANDS_SEP MON_GROUPING POSITIVE_SIGN
		   NEGATIVE_SIGN INT_FRAC_DIGITS FRAC_DIGITS
		   P_CS_PRECEDES P_SEP_BY_SPACE N_CS_PRECEDES
		   N_SEP_BY_SPACE P_SIGN_POSN N_SIGN_POSN
		 ) # hardcoded keys to be sure they are all there
{
	ok ( defined Math::Currency->format($param), sprintf(" \t%-20s = '%s'",$param,Math::Currency->format($param)) );
}

# For subsequent testing, we need to make sure that format is default US
Math::Currency->format($LC_MONETARY->{USD});

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
is ( $dollars,'-$42.00', "display of negative currency" );

$dollars = Math::Currency->new('($42)');	# thanks pjones@pmade.org
is ( $dollars,'-$42.00', "new negative currency" );

$dollars = Math::Currency->new('$4');		# thanks pjones@pmade.org
is ( $dollars,'$4.00', "auto decimal places to FRAC_DIGITS" );


$dollars = Math::Currency->new(56);

ok ( $dollars * 0.555 == 31.08, "multiply followed by auto-round" );

$dollars = Math::Currency->new(20.01);

ok ( $dollars * 1.0 == 20.01, "identity multiply");

$newdollars = $dollars * -1.0;

ok (  $newdollars == -20.01, "negative identity multiply" );

ok ( $dollars->format('INT_CURR_SYMBOL') eq 'USD ', "default format returned" );
ok ( $dollars->format('CURRENCY_SYMBOL',"WOW "), "set a custom format");
ok ( $dollars->format('INT_CURR_SYMBOL') eq 'USD ', "default format copied" );
ok ( $dollars eq 'WOW 20.01', "custom format maintained" );
$dollars->format(''); # defined but false
ok ( $dollars eq '$20.01', "default format restored" );

$euros = Math::Currency->new( -29.95, $LC_MONETARY->{EUR});
ok ( $euros eq '¤-29,95', "foreign currency" );
$newdm = $euros->new(-29.95);
ok ( $euros == $newdm, "two object equality (numeric)" );
ok ( $euros eq $newdm, "two object equality (string)" );

$pounds = Math::Currency->new( 98994.95);
ok ( $pounds eq '$98,994.95', "maintains global format" );
$pounds->format($LC_MONETARY->{GBP});
ok ( $pounds eq '£98994.95', "changes to object format" );

$newpounds = $pounds + 100000;

is ( ref($newpounds), ref($pounds), "autoupgrade to object" );

# monetary_locale testing
use POSIX qw( locale_h );
setlocale(LC_ALL,"en_GB");
ok ( Math::Currency->initialize(), "Get new POSIX locale information");
is ( $FORMAT->{INT_CURR_SYMBOL}, "GBP ", "POSIX format set properly");
$Math::Currency::always_init = 1;
setlocale(LC_ALL,"en_US");
is ( $dollars, '$20.01', "POSIX format reset properly");

print "# Formatting examples:\n";
print "# In Pounds Sterling:	$pounds\n";
print "# In negative Dollars:	$newdollars\n";

$euros = Math::Currency->new( 23459.95, $LC_MONETARY->{EUR});
$Math::Currency::use_int = 1;

print "# In Euros: 	$euros\n";
