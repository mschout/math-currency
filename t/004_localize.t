#!/usr/bin/perl -w
use Test::More tests => 32;
use Math::Currency qw($LC_MONETARY);

# monetary_locale testing
use POSIX qw( locale_h );
my $locale = setlocale( LC_ALL, "en_GB" );
my $format = {};
Math::Currency->localize( \$format );

my @symbols = qw(
      INT_CURR_SYMBOL
      CURRENCY_SYMBOL
      MON_DECIMAL_POINT
      MON_THOUSANDS_SEP
      MON_GROUPING
      POSITIVE_SIGN
      NEGATIVE_SIGN
      INT_FRAC_DIGITS
      FRAC_DIGITS
      P_CS_PRECEDES
      P_SEP_BY_SPACE
      N_CS_PRECEDES
      N_SEP_BY_SPACE
      P_SIGN_POSN
      N_SIGN_POSN);

SKIP: {
    skip ("No locale support", 16) unless Math::Currency->localize();
    pass("Re-initialized locale with en_GB");

    foreach my $param (@symbols)
      {
        ok( defined $format->{$param},
            sprintf( " \t%-20s = '%s'", $param, $format->{$param} ) );
      }

}

SKIP: {
# conveniently the $format is still in scope

    skip ("No locale support", 16) 
    	unless $format->{INT_CURR_SYMBOL} =~ /GBP/;

    use_ok("Math::Currency::en_GB");
    foreach my $param (@symbols)
      {
	my $global_param = $LC_MONETARY->{'en_GB'}->{$param};
        ok( $format->{$param} eq $global_param,
            sprintf( " \t'%s'\t= '%s'", $format->{$param}, $global_param ) );
      }
}
SKIP: {
    my $mckensie = Math::Currency->new("4.56","CAD");
}
