

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'DBIx::Class::ResultSet::XPredicates',
    VERSION_FROM => 'lib/DBIx/Class/ResultSet/XPredicates.pm', # finds \$VERSION
    AUTHOR       => 'Zbigniew Lukasiak (a.u.thor@a.galaxy.far.far.away)',
    ABSTRACT     => 'Module abstract (<= 44 characters) goes here',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                     'DBIx::Class'  => 0.08008,
                    },
);
