use inc::Module::Install;

name 'HTML-FormFu-Model-DBIC';
perl_version '5.008001';
all_from 'lib/HTML/FormFu/Model/DBIC.pm';

requires 'DBD::SQLite';
requires 'DBIx::Class' => '0.08106';
# DBIx::Class 0.08106 switched from DateTime::Format::MySQL to ::SQLite
# Rather than changing our prereqs depending on the installed version
# of DBIx::Class, just bump the required version

requires 'HTML::FormFu' => '0.05000';
requires 'List::MoreUtils';
requires 'Task::Weaken'; # to ensure Scalar::Util was built with weaken()

test_requires 'DateTime::Format::SQLite';

tests_recursive;

&WriteAll;
