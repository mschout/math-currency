#!/usr/bin/perl -w
package Math::Currency::ja_JP;

use Exporter;
use Math::Currency qw($LC_MONETARY $FORMAT);
use vars qw($VERSION @ISA $LANG);

$VERSION = 0.47;
$LANG  = 'ja_JP';
@ISA     = qw(Exporter Math::Currency);

$LC_MONETARY->{ja_JP} = {
	INT_CURR_SYMBOL	=>	'JPY ',
	CURRENCY_SYMBOL	=>	'бя',
	MON_DECIMAL_POINT	=>	'.',
	MON_THOUSANDS_SEP	=>	',',
	MON_GROUPING	=>	'3',
	POSITIVE_SIGN	=>	'',
	NEGATIVE_SIGN	=>	'-',
	INT_FRAC_DIGITS	=>	'0',
	FRAC_DIGITS	=>	'0',
	P_CS_PRECEDES	=>	'1',
	P_SEP_BY_SPACE	=>	'0',
	N_CS_PRECEDES	=>	'1',
	N_SEP_BY_SPACE	=>	'0',
	P_SIGN_POSN	=>	'4',
	N_SIGN_POSN	=>	'4',
};

package Math::Currency::JPY;
use base "Math::Currency::ja_JP";
$LC_MONETARY->{JPY} = \$LC_MONETARY->{ja_JP};

1;
