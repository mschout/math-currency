#!/usr2/local/bin/perl -w
#
# PROGRAM:	Math::Currency.pm	# - 04/26/00 9:10:AM
# PURPOSE:	Perform currency calculations without floating point
#
#------------------------------------------------------------------------------
#   Copyright (c) 2001 John Peacock
#
#   You may distribute under the terms of either the GNU General Public
#   License or the Artistic License, as specified in the Perl README file,
#   with the exception that it cannot be placed on a CD-ROM or similar media
#   for commercial distribution without the prior approval of the author.
#------------------------------------------------------------------------------
eval 'exec /usr2/local/bin/perl -S $0 ${1+"$@"}'
    if 0;

package Math::Currency;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $PACKAGE $FORMAT $LC_MONETARY
	    $accuracy $precision $div_scale $round_mode $use_int);
use Exporter;
use Math::BigFloat 1.27;
use overload	'""'	=>	\&bstr;
use POSIX qw(locale_h);

@ISA = qw(Exporter Math::BigFloat);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT		= qw(
);

@EXPORT_OK	= qw(
	$LC_MONETARY
	$FORMAT
	Money
);

$VERSION = (qw$Revision: 3.2 $)[1]/10;

$PACKAGE = 'Math::Currency';

$LC_MONETARY = {
	USD => {
		INT_CURR_SYMBOL		=> 'USD ',
		CURRENCY_SYMBOL		=> '$',
		MON_DECIMAL_POINT	=> '.',
		MON_THOUSANDS_SEP	=> ',',
		MON_GROUPING		=> '3',
		POSITIVE_SIGN		=> '',
		NEGATIVE_SIGN		=> '-',
		INT_FRAC_DIGITS		=> '2',
		FRAC_DIGITS		=> '2',
		P_CS_PRECEDES		=> '1',
		P_SEP_BY_SPACE		=> '0',
		N_CS_PRECEDES		=> '1',
		N_SEP_BY_SPACE		=> '0',
		P_SIGN_POSN		=> '1',
		N_SIGN_POSN		=> '1',
	      },
	EUR=> {
		INT_CURR_SYMBOL		=> 'EUR ',
		CURRENCY_SYMBOL		=> '¤',
		MON_DECIMAL_POINT	=> ',',
		MON_THOUSANDS_SEP	=> ' ',
		MON_GROUPING		=> '3',
		POSITIVE_SIGN		=> '',
		NEGATIVE_SIGN		=> '-',
		INT_FRAC_DIGITS		=> '2',
		FRAC_DIGITS		=> '2',
		P_CS_PRECEDES		=> '1',
		P_SEP_BY_SPACE		=> '0',
		N_CS_PRECEDES		=> '1',
		N_SEP_BY_SPACE		=> '0',
		P_SIGN_POSN		=> '4',
		N_SIGN_POSN		=> '4',
	      },
	GBP => {
		INT_CURR_SYMBOL		=> 'GBP ',
		CURRENCY_SYMBOL		=> '£',
		MON_DECIMAL_POINT	=> '.',
		MON_THOUSANDS_SEP	=> ',',
		MON_GROUPING		=> '',
		POSITIVE_SIGN 		=> '',
		NEGATIVE_SIGN 		=> '-',
		INT_FRAC_DIGITS 	=> '2',
		FRAC_DIGITS 		=> '2',
		P_CS_PRECEDES 		=> '1',
		P_SEP_BY_SPACE 		=> '0',
		N_CS_PRECEDES 		=> '1',
		N_SEP_BY_SPACE 		=> '0',
		P_SIGN_POSN 		=> '1',
		N_SIGN_POSN 		=> '1',
	      },
};

$FORMAT = {
	INT_CURR_SYMBOL		=> ${localeconv()}{'int_curr_symbol'} 	|| '',
	CURRENCY_SYMBOL		=> ${localeconv()}{'currency_symbol'} 	|| '',
	MON_DECIMAL_POINT	=> ${localeconv()}{'mon_decimal_point'}	|| '',
	MON_THOUSANDS_SEP	=> ${localeconv()}{'mon_thousands_sep'}	|| '',
	MON_GROUPING		=> ${localeconv()}{'mon_grouping'} 	||  0,
	POSITIVE_SIGN		=> ${localeconv()}{'positive_sign'} 	|| '',
	NEGATIVE_SIGN		=> ${localeconv()}{'negative_sign'} 	|| '-',
	INT_FRAC_DIGITS		=> ${localeconv()}{'int_frac_digits'} 	||  0,
	FRAC_DIGITS		=> ${localeconv()}{'frac_digits'} 	||  0,
	P_CS_PRECEDES		=> ${localeconv()}{'p_cs_precedes'}  	||  0,
	P_SEP_BY_SPACE		=> ${localeconv()}{'p_sep_by_space'}  	||  0,
	N_CS_PRECEDES		=> ${localeconv()}{'n_cs_precedes'}  	||  0,
	N_SEP_BY_SPACE		=> ${localeconv()}{'n_sep_by_space'}  	||  0,
	P_SIGN_POSN		=> ${localeconv()}{'p_sign_posn'}  	||  1,
	N_SIGN_POSN		=> ${localeconv()}{'n_sign_posn'}  	||  0,
};

unless ( $FORMAT->{CURRENCY_SYMBOL} ) # no active locale
{
	$FORMAT = $LC_MONETARY->{USD};
}

# Set class constants
$round_mode = 'even';  # Banker's rounding obviously
$accuracy   = undef;
$precision  = $FORMAT->{FRAC_DIGITS} > 0 ? -$FORMAT->{FRAC_DIGITS} : 0;
$div_scale  = 40;
$use_int    = 0;


# Preloaded methods go here.
############################################################################
sub new		#05/10/99 3:13:PM
############################################################################

{
	my $proto  = shift;
	my $class  = ref($proto) || $proto;
	my $parent = $proto if ref($proto);

	my $value = shift;

	if ( (caller)[0] =~ /Math\::BigInt/ ) # only when called from objectify()
	{
		return Math::BigFloat->new($value);
	}

	$value =~ tr/()-0-9.//cd;	#strip any formatting characters
	$value = "-$value" if $value=~s/(^\()|(\)$)//g;	# handle parens
	my $self;
	my $format = shift;
	if ( $format )
	{
		$self = Math::BigFloat->new($value,undef,
			-$format->{FRAC_DIGITS});
		bless $self, $class;
		$self->format($format);
	}
	elsif ( $parent and defined $parent->{format} )	# if we are cloning an existing instance
	{
		$self = Math::BigFloat->new($value, undef,
			-$parent->format->{FRAC_DIGITS});
		bless $self, $class;
		$self->format($parent->format);
	}
	else
	{
		$self = Math::BigFloat->new($value, undef,
			-$FORMAT->{FRAC_DIGITS});
		bless $self, $class;
	}
	return $self;
}	##new


############################################################################
sub Money		#05/10/99 4:16:PM
############################################################################

{
	return $PACKAGE->new(@_);
}	##Money

############################################################################
sub bstr		#05/10/99 3:52:PM
############################################################################

{
	my $self  = shift;
	my $value = Math::BigFloat::bstr($self);
	my $neg =  ($value =~ tr/-//d);
	my $dp = index($value, ".");
	my $myformat = $self->format();
	my $sign = $neg		? $myformat->{NEGATIVE_SIGN}
				: $myformat->{POSITIVE_SIGN};
	my $curr = $use_int 	? $myformat->{INT_CURR_SYMBOL}
				: $myformat->{CURRENCY_SYMBOL};
	my $digits = $use_int 	? $myformat->{INT_FRAC_DIGITS}
				: $myformat->{FRAC_DIGITS};
	my $formtab =
	[
	    [
		['($value$curr)'   ,'($value $curr)'   ,'($value $curr)'   ],
		['$sign$value$curr','$sign$value $curr','$sign$value $curr'],
		['$value$curr$sign','$value $curr$sign','$value$curr $sign'],
		['$value$sign$curr','$value $sign$curr','$value$sign $curr'],
		['$value$curr$sign','$value $curr$sign','$value$curr $sign'],
	    ],
	    [
		['($curr$value)'   ,'($curr $value)'    ,'($curr $value)'   ],
		['$sign$curr$value','$sign$curr $value' ,'$sign $curr$value'],
		['$curr$value$sign','$curr $value$sign' ,'$curr$value $sign'],
		['$sign$curr$value', '$sign$curr $value','$sign $curr$value'],
		['$curr$sign$value', '$curr$sign $value','$curr $sign$value'],
	    ],
	];

	if ( $dp < 0 )
	{
		$value .= '.' . '0' x $digits;
	}
	elsif ( (length($value) - $dp - 1) < $digits )
	{
		$value .= '0' x ( $digits - $dp )
	}

	($value = reverse "$value") =~ s/\+//;

	# make sure there is a leading 0 for values < 1
	if ( substr($value,-1,1) eq '.' )
	{
		$value .= "0";
	}
	$value =~ s/\./$myformat->{MON_DECIMAL_POINT}/;
	$value =~ s/(\d{$myformat->{MON_GROUPING}})(?=\d)(?!\d*\.)/$1$myformat->{MON_THOUSANDS_SEP}/g;
	$value = reverse $value;

	eval '$value = "' .
	    ( $neg
		?   $formtab->	[$myformat->{N_CS_PRECEDES}]
				[$myformat->{N_SIGN_POSN}]
				[$myformat->{N_SEP_BY_SPACE}]
		:   $formtab->	[$myformat->{P_CS_PRECEDES}]
		    		[$myformat->{P_SIGN_POSN}]
		    		[$myformat->{P_SEP_BY_SPACE}]
	    ) . '"';

	return $value;
}	##stringify

############################################################################
sub format		#05/17/99 1:58:PM
############################################################################

{
	my $self = shift;
	my $key = shift;	# do they want to display or set?
	my $value = shift;      # did they supply a value?
	my $source = \$FORMAT;	# default format rules

	if ( ref($self) )
	{
		if ( defined $self->{format} )
		{
			if ( defined $key and $key eq '' )
			{
				delete $self->{format};
				$source = \$FORMAT;
			}
			else
			{
				$source = \$self->{format};
			}
		}
		elsif ( defined $key ) 		# get/set a parameter
		{
			if (defined $value or ref($key) eq "HASH")	# have to copy global format
			{
				while (  my($k,$v) = each %{$FORMAT} )
				{
					$self->{format}{$k} = $v;
				}
				$source = \$self->{format};
			}
		}
	}


	if ( defined $key )	# otherwise just return
	{
		if ( ref($key) eq "HASH" )	# must be trying to replace all
		{
			$$source = $key;
		}
		else 				# get/set just one parameter
		{
			return $$source->{$key} unless defined $value;
			$$source->{$key} = $value;
		}
	}
	return $$source;
}	##format

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

Math::Currency - Exact Currency Math with Formatting and Rounding

=head1 SYNOPSIS

 use Math::Currency qw(Money $LC_MONETARY);
 $dollar = Math::Currency->new("$12,345.67");
 $taxamt = $dollar * 0.28;
 # this sets the default format for all objects w/o their own format
 Math::Currency->format( $LC_MONETARY->{EUR} );
 $euro = Money(12345.67);
 $euro_string = Money(12345.67)->bstr();
 # or if you already have a Math::Currency object
 $euro_string = "$euro";

=head1 DESCRIPTION

Currency math is actually more closely related to integer math than it is to
floating point math.  Rounding errors on addition and subtraction are not
allowed and division/multiplication should never create more accuracy than the
original values.  All currency values should round to the closest cent or
whatever the local equivalent should happen to be.

All common mathematical operations are overloaded, so once you initialize a
currency variable, you can treat it like any number and the module will do
the right thing.  This module is a thin layer over Math::BigFloat which
is itself a layer over Math::BigInt.

=head1 Output Formatting

Each currency value can have an individual format or the global currency
format can be changed to reflect local usage.  I used the suggestions in Tom
Christiansen's L<PerlTootC|http://www.perl.com/language/misc/perltootc.html#Translucent_Attributes>
to implement translucent attributes.  If you have set your locale values
correctly, this module will pick up your local settings or US standards if you
haven't.

=head2 Currency Symbol

The locale definition includes two different Currency Symbol strings: one
is the native character(s), like $ or £ or DM; the other is the three
character string defined by the ISO4217 specification followed by the
normal currency seperation character (frequently space).  The default
behavior is to always display the native CURRENCY_SYMBOL unless a global
parameter is set:

    $Math::Currency::use_int = 1; # print the currency symbol text

where the INT_CURR_SYMBOL text will used instead.

=head2 Predefined Locales

There are currently three predefined Locale LC_MONETARY formats:

    USD = United States dollars (the default if no locale)
    EUR = One possible Euro format (no single standard, yet)
    GBP = British Pounds Sterling

These hashes can be retrieved using the optional export $LC_MONETARY, like
this:

    $format = $LC_MONETARY->{EUR};

This $format hash can be used to set either object formats (see L<"Object Formats">)
or can be used to set the package format (see L<"Global Format">) that all
objects will inherit by default.

=head2 Global Format

Global formatting can be changed by setting the package global format like
this:

    Math::Currency->format($LC_MONETARY->{USD});

=head2 Object Formats

Any object can have it's own format different from the current global format,
like this:

    $pounds  = Math::Currency->new(1000, $LC_MONETARY->{GBP});
    $dollars = Math::Currency->new(1000); # inherits default US format
    $dollars->format( $LC_MONETARY->{USD} ); # explicit object format

=head2 Format Parameters

The format must contains all of the commonly configured LC_MONETARY
Locale settings.  For example, these are the values of the default US format
(with comments):

  {
    INT_CURR_SYMBOL    => 'USD',  # ISO currency text
    CURRENCY_SYMBOL    => '$',    # Local currency character
    MON_DECIMAL_POINT  => '.',    # Decimal seperator
    MON_THOUSANDS_SEP  => ',',    # Thousands seperator
    MON_GROUPING       => '3',    # Grouping digits
    POSITIVE_SIGN      => '',     # Local positive sign (see below)
    NEGATIVE_SIGN      => '-',    # Local negative sign (see below)
    INT_FRAC_DIGITS    => '2',    # Default Intl. precision
    FRAC_DIGITS        => '2',    # Local precision
    P_CS_PRECEDES      => '1',    # Currency symbol location
    P_SEP_BY_SPACE     => '0',    # Space between Currency and value
    N_CS_PRECEDES      => '1',    # Negative version of above
    N_SEP_BY_SPACE     => '0',    # Negative version of above
    P_SIGN_POSN        => '1',    # Position of positive sign (see below)
    N_SIGN_POSN        => '1',    # Position of negative sign (see below)
  }

Each of the formatting parameters can be individually changed at the object
or class (global) level; if an object is currently sharing the global format,
all the global parameters will be copied prior to setting the overrided
parameters.  For example:

    $dollars = Math::Currency->new(1000); # inherits default US format
    $dollars->format('CURRENCY_SYMBOL',' Bucks'); # now has its own format
    $dollars->format('P_CS_PRECEDES',0); # now has its own format
    print $dollars; # displays as "1000 Bucks"

Or you can also set individual elements of the current global format:

   Math::Currency->format('CURRENCY_SYMBOL',' Bucks'); # global changed

The [NP]_SIGN_POSN parameter determines how positive and negative signs are
displayed.  [NP]_CS_PRECEEDS determines where the currency symbol is shown.
[NP]_SEP_BY_SPACE determines whether the currency symbol cuddles the value
or not.  The following table shows the relationship between these three
parameters:

                                               p_sep_by_space
                                         0          1          2

 p_cs_precedes = 0   p_sign_posn = 0    (1.25$)    (1.25 $)   (1.25 $)
                     p_sign_posn = 1    +1.25$     +1.25 $    +1.25 $
                     p_sign_posn = 2     1.25$+     1.25 $+    1.25$ +
                     p_sign_posn = 3     1.25+$     1.25 +$    1.25+ $
                     p_sign_posn = 4     1.25$+     1.25 $+    1.25$ +

 p_cs_precedes = 1   p_sign_posn = 0   ($1.25)   ($ 1.25)   ($ 1.25)
                     p_sign_posn = 1   +$1.25    +$ 1.25    + $1.25
                     p_sign_posn = 2    $1.25+    $ 1.25+     $1.25 +
                     p_sign_posn = 3   +$1.25    +$ 1.25    + $1.25
                     p_sign_posn = 4   $+1.25    $+ 1.25    $ +1.25

(the negative variants are similar).


=head1 AUTHOR

John Peacock <jpeacock@rowman.com>

=head1 SEE ALSO

perl(1).
perllocale
Math::BigFloat
Math::BigInt

=cut
