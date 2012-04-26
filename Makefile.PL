use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'Sort::MultipleFields',
    META_MERGE => {
        license => 'other',
        resource => {
	    repository => 'https://github.com/DrHyde/perl-modules-Sort-MultipleFields'
        }
    },
    VERSION_FROM => 'lib/Sort/MultipleFields.pm',
    PREREQ_PM    => {
	Test::More      => 0,
	Scalar::Util    => 0,
        # Exporter      => 0,   # in core since beginning of time
    },
);
