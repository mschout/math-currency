package Math::Currency;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $PACKAGE $CLASSDATA);
require Exporter;
require Math::FixedPrecision;
use overload 	'+'		=>	\&add,
				'-'		=>	\&subtract,
				'*'		=>	\&multiply,
				'/'		=>	\&divide,
				'<=>'	=>	\&spaceship,
                '""'	=>	\&stringify,
				'0+'	=>	\&numify,
				'abs'	=>	\&absolute,
				'bool'	=>	\&boolean,
				;
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

$VERSION = '0.06';

$PACKAGE = 'Math::Currency';

$CLASSDATA = {
		SEPARATOR	=>	${localeconv()}{'mon_thousands_sep'} || ',',
		DECIMAL		=>	${localeconv()}{'mon_decimal_point'} || '.',
};
if ( ${localeconv()}{'p_cs_precedes'} eq '0' )
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
#	mon_grouping         = 3 (get with unpack "C*" $locale_values->{'mon_decimal_point})
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

	my $self = bless {}, $class;

	my $value = shift;
	my $format = shift;
	$self->{VAL} = Math::FixedPrecision->new($value,2);
	$self->format($format) if $format;
	return $self;
}	##new

############################################################################
sub Money		#05/10/99 4:16:PM
############################################################################

{
	return $PACKAGE->new(@_);
}	##Money

##########################################################################
#sub _new		#05/10/99 5:06:PM
#				 only use for values already offset by 100
###########################################################################

#{
#	my $proto  = shift;
#	my $class  = ref($proto) || $proto;
#	my $parent = ref($proto) && $proto;

#	my $self = bless {}, $class;

#	my $value = shift;
#	my $format = shift;
#	%$self = %$proto if ref $proto;
#	$self->{VAL} = Math::FixedPrecision->_new($value,2);
#	$self->format($format) if $format;
#	return $self;
#}	##new_int

##########################################################################
sub add		#05/10/99 5:00:PM
##########################################################################

{
	my($oper1,$oper2,$inverted) = @_;

	unless ( ref $oper2 )
	{
		$oper2 = $PACKAGE->new($oper2);
	}

	return ( $PACKAGE->new( $oper1->{VAL} + $oper2->{VAL},$oper1->format ) ) unless $inverted;
	return ( $PACKAGE->new( $oper2->{VAL} + $oper1->{VAL},$oper2->format ) )
}	##add


##########################################################################
sub subtract		#05/10/99 5:05:PM
##########################################################################

{
	my($oper1,$oper2,$inverted) = @_;

	unless ( ref $oper2 )
	{
		$oper2 = $PACKAGE->new($oper2);
	}

	return ( $PACKAGE->new( $oper1->{VAL} - $oper2->{VAL},$oper1->format ) ) unless $inverted;
	return ( $PACKAGE->new( $oper2->{VAL} - $oper1->{VAL},$oper2->format ) )
}	##subtract


##########################################################################
sub multiply		#05/10/99 5:12:PM
##########################################################################

{
	my($oper1,$oper2,$inverted) = @_;

	unless ( ref $oper2 )
	{
		$oper2 = $PACKAGE->new( $oper2 );
	}

	return $PACKAGE->new( $oper1->{VAL} * $oper2->{VAL},$oper1->format );
	
}	##multiply

##########################################################################
sub divide		#05/10/99 5:12:PM
##########################################################################

{
	my($oper1,$oper2,$inverted) = @_;

	unless ( ref $oper2 )
	{
		$oper2 = $PACKAGE->new($oper2);
	}

	return ( $PACKAGE->new( $oper1->{VAL} / $oper2->{VAL},$oper1->format ) ) unless $inverted;
	return ( $PACKAGE->new( $oper2->{VAL} / $oper1->{VAL},$oper2->format ) )
	
}	##divide

##########################################################################
sub spaceship		#05/10/99 3:48:PM
##########################################################################

{
	my($dollar1,$dollar2,$inverted) = @_;

	unless ( ref $dollar2 )
	{
		$dollar2 = $PACKAGE->new($dollar2);
	}

	my $sgn = $inverted ? -1 : 1;

	return $sgn * ( $dollar1->{VAL}  <=> $dollar2->{VAL}  );
	
}	##spaceship

############################################################################
sub stringify		#05/10/99 3:52:PM
############################################################################

{
	my $self  = shift;
	my $value = abs($self->{VAL}) + 0;
	my $neg   = $self->{VAL} < 0 ? 1 : 0; 
	($value = reverse "$value") =~ s/\+//;
	if ( length($value) < 3 )
	{
		$value .= "0" x ( 3 - length($value) ) ;
	}
	$value =~ s/\./${$self->format}{DECIMAL}/;
	$value =~ s/(\d{3})(?=\d)(?!\d*\.)/$1${$self->format}{SEPARATOR}/g;
	$value = reverse $value;
	if ( $neg )
	{
		return "(${$self->format}{PREFIX}$value${$self->format}{POSTFIX})";
	}
	else
	{
		return "${$self->format}{PREFIX}$value${$self->format}{POSTFIX}";
	}
}	##stringify

############################################################################
sub numify		#05/11/99 12:02:PM
############################################################################

{
	my $self = shift;
	return ( ($self->{VAL} + 50)/100 );
}	##numify

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

	$self->{Format} = $_[0] if @_;
	if ( defined $self->{Format} )
	{
		return $self->{Format};
	}
	else 
	{
		return $CLASSDATA;
	}
}	##format

############################################################################
sub absolute		#06/15/99 4:47:PM
############################################################################

{
	my $self = shift;
	return $PACKAGE->new( abs($self->{VAL}) );
}	##absolute

############################################################################
sub boolean		#06/28/99 9:47:AM
############################################################################

{
    my($object) = @_;
    my($result);

    eval
    {
        $result = $object->{VAL}->is_empty();
    };
    return(! $result);
}	##boolean

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Math::Currency - Exact Currency Math with Formatting and Rounding

=head1 SYNOPSIS

  use Math::Currency;
  $dollar = Math::Currency->new("$12,345.67");
  $taxamt = $dollar * 0.28;
  Math::Currency->format(
	{ 
		PREFIX    =>  '',
		SEPARATOR =>  ' ',
		DECIMAL   =>  ',',
		POSTFIX   =>  ' DM'
	});
  $deutschmark = Money(12345.67);

=head1 DESCRIPTION

Currency math is actually more closely related to integer math than it is to
floating point math.  Rounding errors on addition and subtraction are not
allowed and division/multiplication should never create more accuracy than the
original values.  All currency values should round to the closest cent or
whatever the local equivalent should happen to be.

The default formatting methods 
A currency value can
have an individual format or the global currency format can be changed to
reflect local usage.  I used the suggestions in Tom Christiansen's L<PerlTootC|http://www.perl.com/language/misc/perltootc.html#Translucent_Attributes>
to implement translucent attributes.

All common mathematical operations are overloaded, so once you initialize a
currency variable, you can treat it like any number and get what you would
expect.  

=head1 AUTHOR

John Peacock <JPeacock@UnivPress.com>

=head1 SEE ALSO

perl(1).
perllocale


=cut
