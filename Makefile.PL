use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Math::Currency',
    'VERSION_FROM' => 'Currency.pm', # finds $VERSION
    'PREREQ_PM' => {	Math::BigFloat	=> 1.27,
			Math::BigInt	=> 1.39,
			},
);
