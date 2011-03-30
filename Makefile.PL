use inc::Module::Install;

if ( -e 'MANIFEST.SKIP' ) {
    system( 'pod2text lib/HTML/FormFu/Model/DBIC.pm > README' );
}

name 'HTML-FormFu-Model-DBIC';
perl_version '5.008001';
all_from 'lib/HTML/FormFu/Model/DBIC.pm';

repository 'git://github.com/fireartist/HTML-FormFu-Model-DBIC.git';

requires 'DBD::SQLite';
requires 'DBIx::Class' => '0.08108';
# DBIx::Class 0.08106 switched from DateTime::Format::MySQL to ::SQLite
# Rather than changing our prereqs depending on the installed version
# of DBIx::Class, just bump the required version

requires 'HTML::FormFu' => '0.09000';
requires 'List::MoreUtils';
requires 'Task::Weaken'; # to ensure Scalar::Util was built with weaken()
requires 'YAML::Syck';

test_requires 'DateTime::Format::SQLite';
test_requires 'SQL::Translator'; # for $schema->deploy()

tests_recursive;

&WriteAll;
