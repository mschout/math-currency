use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Math::Currency',
    'VERSION_FROM' => 'Currency.pm', # finds $VERSION
    'PREREQ_PM' => { Math::FixedPrecision => 0.10,
					 Math::BigFloat => 0.01,
				   },
);
