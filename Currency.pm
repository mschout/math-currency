#!/usr2/local/bin/perl -w
#
# PROGRAM:	Math::Currency.pm	# - 04/26/00 9:10:AM
# PURPOSE:	Perform currency calculations without floating point
#
#------------------------------------------------------------------------------
#   Copyright (c) 2000 John Peacock
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
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $PACKAGE $CLASSDATA);
use Exporter;
use Math::FixedPrecision(0.11);
use overload	'""'	=>	\&stringify;
use POSIX qw(locale_h);

@ISA = qw(Exporter Math::FixedPrecision);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT		= qw(
);

@EXPORT_OK	= qw(
	Money
);

$VERSION = '0.11';

$PACKAGE = 'Math::Currency';

$CLASSDATA = {
		SEPARATOR	=>	${localeconv()}{'mon_thousands_sep'} || ',',
		DECIMAL		=>	${localeconv()}{'mon_decimal_point'} || '.',
		FRAC_DIGITS =>	${localeconv()}{'frac_digits'} || '2',
		GROUPING	=>	defined ${localeconv()}{'mon_grouping'} &&
						unpack("C*",${localeconv()}{'mon_grouping'}) || '3',
};
if ( defined ${localeconv()}{'p_cs_precedes'} and ${localeconv()}{'p_cs_precedes'} eq '0' )
{
	$CLASSDATA->{PREFIX}	= '';
	$CLASSDATA->{POSTFIX}	= ${localeconv()}{'currency_symbol'} || '$';
}
else 
{
	$CLASSDATA->{PREFIX}	= ${localeconv()}{'currency_symbol'} || '$';
	$CLASSDATA->{POSTFIX}	= '';
}
#	currency_symbol      = $
#   frac_digits          = 2
#	mon_decimal_point    = .
#	mon_grouping         = 3 (get with unpack "C*" $locale_values->{'mon_grouping})
#	mon_thousands_sep    = ,
#	n_cs_precedes        = 1
#	n_sep_by_space       = 0
#	n_sign_posn          = 0
#	negative_sign        = -
#	p_cs_precedes        = 1
#	p_sep_by_space       = 0
#	p_sign_posn          = 3


# Preloaded methods go here.
############################################################################
sub new		#05/10/99 3:13:PM
############################################################################

{
	my $proto  = shift;
	my $class  = ref($proto) || $proto;
	my $parent = ref($proto) && $proto;

	my $value = shift;
	$value =~ tr/-0-9.//cd;	#strip any formatting characters
	my $self;
	my $format = shift;
	if ( $format )
	{
		$self = Math::FixedPrecision->new($value,$format->{FRAC_DIGITS});
		bless $self, $class;
		$self->format($format);
	}
	elsif ( $parent and $parent->format )	# if we are cloning an existing instance
	{
		$self = Math::FixedPrecision->new($value,$parent->format->{FRAC_DIGITS}); # = bless {}, $class
		bless $self, $class;
		$self->format($parent->format);
	}
	else 
	{
		$self = Math::FixedPrecision->new($value,$CLASSDATA->{FRAC_DIGITS}); # = bless {}, $class
		bless $self, $class;
	}
	return $self;
}	##new

############################################################################
sub _new		#07/28/00 4:50:PM
############################################################################

{
	my $proto  = shift;
	my $class  = ref($proto) || $proto;
	my $parent = ref($proto) && $proto;

	my $value = shift;
	$value =~ tr/-0-9.//cd;	#strip any formatting characters
	my $self;
	my $dp = shift;
	if ( $parent and $parent->format )	# if we are cloning an existing instance
	{
		$self = Math::FixedPrecision->new($value,$parent->format->{FRAC_DIGITS}); # = bless {}, $class
		bless $self, $class;
		$self->format($parent->format);
	}
	else 
	{
		$self = Math::FixedPrecision->new($value,$CLASSDATA->{FRAC_DIGITS}); # = bless {}, $class
		bless $self, $class;
	}
	return $self;
}	##_new

############################################################################
sub Money		#05/10/99 4:16:PM
############################################################################

{
	return $PACKAGE->new(@_);
}	##Money

############################################################################
sub stringify		#05/10/99 3:52:PM
############################################################################

{
	my $self  = shift;
	my $value = abs($self->{VAL}) + 0;
	my $neg   = $self->{VAL} < 0 ? 1 : 0; 
	my $dp = length($value) - index($value, ".") - 1;
	$value .= "0" x ( ${$self->format}{FRAC_DIGITS} - $dp ) if $dp < ${$self->format}{FRAC_DIGITS};
	($value = reverse "$value") =~ s/\+//;
	if ( substr($value,-1,1) eq '.' )	# make sure there is a leading 0 for values < 1
	{
		$value .= "0";
	}
	$value =~ s/\./${$self->format}{DECIMAL}/;
	$value =~ s/(\d{${$self->format}{GROUPING}})(?=\d)(?!\d*\.)/$1${$self->format}{SEPARATOR}/g;
	$value = reverse $value;
	if ( $neg )
	{
		return "(".$self->PREFIX.$value.$self->POSTFIX.")";
	}
	else
	{
		return $self->PREFIX.$value.$self->POSTFIX;
	}
}	##stringify

############################################################################
sub format		#05/17/99 1:58:PM
############################################################################

{
	my $self = shift;
	my $class = ref($self ) || $self;

	unless ( ref $self )
	{
		$CLASSDATA = $_[0] if @_;
		return $CLASSDATA;
	}

	$self->{format} = $_[0] if @_;
	if ( defined $self->{format} )
	{
		return $self->{format};
	}
	else 
	{
		return $CLASSDATA;
	}
}	##format

############################################################################
sub FRAC_DIGITS		#6/12/2000 3:28PM
############################################################################

{
	my $self = shift;
	my $class = ref($self ) || $self;

	unless ( ref $self )
	{
		return "$CLASSDATA->{FRAC_DIGITS}";
	}

	if ( defined $self->{format} )
	{
		return "${$self->format}{FRAC_DIGITS}";
	}
	else 
	{
		return "$CLASSDATA->{FRAC_DIGITS}";
	}
}	##FRAC_DIGITS

#############################################################################
sub POSTFIX		#6/12/2000 3:28PM
############################################################################

{
	my $self = shift;
	my $class = ref($self ) || $self;

	unless ( ref $self )
	{
		return "$CLASSDATA->{POSTFIX}";
	}

	if ( defined $self->{format} )
	{
		return "${$self->format}{POSTFIX}";
	}
	else 
	{
		return "$CLASSDATA->{POSTFIX}";
	}
}	##POSTFIX

############################################################################
sub PREFIX		#6/12/2000 3:28PM
############################################################################

{
	my $self = shift;
	my $class = ref($self ) || $self;

	unless ( ref $self )
	{
		return "$CLASSDATA->{PREFIX}";
	}

	if ( defined $self->{format} )
	{
		return "${$self->format}{PREFIX}";
	}
	else 
	{
		return "$CLASSDATA->{PREFIX}";
	}
}	##PREFIX

############################################################################
sub SEPARATOR		#6/12/2000 3:28PM
############################################################################

{
	my $self = shift;
	my $class = ref($self ) || $self;

	unless ( ref $self )
	{
		return "$CLASSDATA->{SEPARATOR}";
	}

	if ( defined $self->{format} )
	{
		return "${$self->format}{SEPARATOR}";
	}
	else 
	{
		return "$CLASSDATA->{SEPARATOR}";
	}
}	##SEPARATOR

############################################################################
sub DECIMAL		#6/12/2000 3:28PM
############################################################################

{
	my $self = shift;
	my $class = ref($self ) || $self;

	unless ( ref $self )
	{
		return "$CLASSDATA->{DECIMAL}";
	}

	if ( defined $self->{format} )
	{
		return "${$self->format}{DECIMAL}";
	}
	else 
	{
		return "$CLASSDATA->{DECIMAL}";
	}
}	##DECIMAL

############################################################################
sub GROUPING		#6/12/2000 3:28PM
############################################################################

{
	my $self = shift;
	my $class = ref($self ) || $self;

	unless ( ref $self )
	{
		return "$CLASSDATA->{GROUPING}";
	}

	if ( defined $self->{format} )
	{
		return "${$self->format}{GROUPING}";
	}
	else 
	{
		return "$CLASSDATA->{GROUPING}";
	}
}	##GROUPING

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

Math::Currency - Exact Currency Math with Formatting and Rounding

=head1 SYNOPSIS

  use Math::Currency qw(Money);
  $dollar = Math::Currency->new("$12,345.67");
  $taxamt = $dollar * 0.28;
  Math::Currency->format(
	{ 
		PREFIX      =>     '',
		SEPARATOR   =>    ' ',
		DECIMAL     =>    ',',
		POSTFIX     =>  ' DM',
		FRAC_DIGITS =>      2,
		GROUPING    =>      3,
	});
  $deutschmark = Money(12345.67);
  $deutschmark_string = Money(12345.67)->stringify();
  # or if you already have a Math::Currency object
  $deutschmark_string = "$deutschmark"; 

=head1 DESCRIPTION

Currency math is actually more closely related to integer math than it is to
floating point math.  Rounding errors on addition and subtraction are not
allowed and division/multiplication should never create more accuracy than the
original values.  All currency values should round to the closest cent or
whatever the local equivalent should happen to be.

Each currency value can have an individual format or the global currency 
format can be changed to reflect local usage.  I used the suggestions in Tom 
Christiansen's L<PerlTootC|http://www.perl.com/language/misc/perltootc.html#Translucent_Attributes>
to implement translucent attributes.  If you have set your locale values 
correctly, this module will pick up your local settings or US standards if you 
haven't.

All common mathematical operations are overloaded, so once you initialize a
currency variable, you can treat it like any number and the module will do
the right thing.  This module is a thin layer over Math::FixedPrecision which
is itself a layer over Math::BigFloat which is itself a layer over Math::BigInt.
The module optionally exports a single function Money() which can be used
instead of Math::Currency->new().																		  

=head1 AUTHOR

John Peacock <jpeacock@rowman.com>

=head1 SEE ALSO

perl(1).
perllocale
Math::FixedPrecision

=cut