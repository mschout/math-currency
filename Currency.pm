package Math::Currency;

use strict;
use integer;
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
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

require Exporter;
require Math::BigInt;

@ISA = qw(Exporter Math::BigInt);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT		= qw(
);

@EXPORT_OK	= qw(
	Money
);

$VERSION = '0.03';

my $package = 'Math::Currency';

my $ClassData = {
		SIGN		=>	'-',
		PREFIX		=>	'$',
		SEPARATOR	=>	',',
		DECIMAL		=>	'.',
		POSTFIX		=>	'',
};

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
	my $decimal = 0;
	$value =~ tr/0-9.-//cd;		# Clean out non-numeric characters

	# Normalize the number to 1234567.89
	if ( ( $decimal = length($value) - index($value,'.') - 1 ) != length($value) )	# Already has a decimal
	{
		$value =~ tr/0-9-//cd;	# Strip the decimal
		if ( $decimal <= 2 )	# Not enough decimal places
		{
			$value .= '0' x ( 2 - $decimal );
		}
		else					# Too many decimal places 
		{
			$decimal = length($value) - $decimal + 2;
			my $remainder = substr( $value, $decimal, 1 );
			$value = substr( $value, 0, $decimal );
			if ( $remainder >= 5 )
			{
				$value += 1;
			}
		}
	}
	else 
	{
		$value .= '00';			# Has no decimal to start with
	}

	%$self = %$proto if ref $proto;
	$self->{VAL} = Math::BigInt->new($value);
	$self->format($format) if $format;
	return $self;
}	##new

############################################################################
sub Money		#05/10/99 4:16:PM
############################################################################

{
	return $package->new(@_);
}	##Money

############################################################################
sub _new		#05/10/99 5:06:PM
				# only use for values already offset by 100
############################################################################

{
	my $proto  = shift;
	my $class  = ref($proto) || $proto;
	my $parent = ref($proto) && $proto;

	my $self = bless {}, $class;

	my ( $value ) = shift;
	%$self = %$proto if ref $proto;
	$self->{VAL} = Math::BigInt->new($value);
	return $self;
}	##new_int

############################################################################
sub add		#05/10/99 5:00:PM
############################################################################

{
	my($oper1,$oper2,$inverted) = @_;

	unless ( ref $oper2 )
	{
		$oper2 = $package->new($oper2);
	}

	return ( $package->_new($oper1->{VAL} + $oper2->{VAL}) ) unless $inverted;
	return ( $package->_new($oper2->{VAL} + $oper1->{VAL}) )
}	##add


############################################################################
sub subtract		#05/10/99 5:05:PM
############################################################################

{
	my($oper1,$oper2,$inverted) = @_;

	unless ( ref $oper2 )
	{
		$oper2 = $package->new($oper2);
	}

	return ( $package->_new($oper1->{VAL} - $oper2->{VAL}) ) unless $inverted;
	return ( $package->_new($oper2->{VAL} - $oper1->{VAL}) )
}	##subtract


############################################################################
sub multiply		#05/10/99 5:12:PM
############################################################################

{
	my($oper1,$oper2,$inverted) = @_;

	unless ( ref $oper2 )
	{
		$oper2 = $package->new( $oper2 );
	}

	return $package->_new( ($oper1->{VAL} * $oper2->{VAL} + 50) / 100 );
	
}	##multiply

############################################################################
sub divide		#05/10/99 5:12:PM
############################################################################

{
	my($oper1,$oper2,$inverted) = @_;

	unless ( ref $oper2 )
	{
		$oper2 = $package->new($oper2);
	}

	return ( $package->_new( ($oper1->{VAL} * 100) / $oper2->{VAL}) ) unless $inverted;
	return ( $package->_new( ($oper2->{VAL} * 100) / $oper1->{VAL}) )
	
}	##divide

############################################################################
sub spaceship		#05/10/99 3:48:PM
############################################################################

{
	my($dollar1,$dollar2,$inverted) = @_;

	unless ( ref $dollar2 )
	{
		$dollar2 = $package->new($dollar2);
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
	substr($value,2,0) = ${$self->format}{DECIMAL};
	$value=~ s/(\d{3})(?=\d)(?!\d*\.)/$1${$self->format}{SEPARATOR}/g;
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
		$ClassData = @_[0] if @_;
		return $ClassData;
	}

	$self->{Format} = @_[0] if @_;
	if ( defined $self->{Format} )
	{
		return $self->{Format};
	}
	else 
	{
		return $ClassData;
	}
}	##format

############################################################################
sub absolute		#06/15/99 4:47:PM
############################################################################

{
	my $self = shift;
	return $package->_new( abs($self->{VAL}) );
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

Math::Currency - Perl extension for performing exact currency math

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

This module employs Math::BigInt to perform its actual calculations (although
I plan to change that to Bit::Vector soon), and has a flexible formatting
scheme that should cover most formats in use worldwide.  A currency value can
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


=cut
