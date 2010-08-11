#!/usr/bin/perl -w
package Math::Currency::de_DE;

use Exporter;
use Math::Currency qw($LC_MONETARY $FORMAT);
use vars qw($VERSION @ISA $LANG);

$VERSION = 0.47;
$LANG  = 'de_DE.utf8';
use utf8;
@ISA     = qw(Exporter Math::Currency);

$LC_MONETARY->{de_DE} = {
	INT_CURR_SYMBOL	=>	'EUR ',
	CURRENCY_SYMBOL	=>	'€',
	MON_DECIMAL_POINT	=>	',',
	MON_THOUSANDS_SEP	=>	'.',
	MON_GROUPING	=>	'3',
	POSITIVE_SIGN	=>	'',
	NEGATIVE_SIGN	=>	'-',
	INT_FRAC_DIGITS	=>	'2',
	FRAC_DIGITS	=>	'2',
	P_CS_PRECEDES	=>	'0',
	P_SEP_BY_SPACE	=>	'1',
	N_CS_PRECEDES	=>	'0',
	N_SEP_BY_SPACE	=>	'1',
	P_SIGN_POSN	=>	'1',
	N_SIGN_POSN	=>	'1',
};

package Math::Currency::EUR;
use base "Math::Currency::de_DE";
$LC_MONETARY->{EUR} = \$LC_MONETARY->{de_DE};

1;
