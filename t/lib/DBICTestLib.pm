package DBICTestLib;
use strict;
use warnings;

use DBI;

use base 'Exporter';

our @EXPORT_OK = qw/ new_db /;

END {
    if ( -f 't/test.db') {
        unlink 't/test.db';
    }
}

sub new_db {
    
    if ( -f 't/test.db' ) {
        unlink 't/test.db'
            or die $!;
    }
    
    my $dbh = DBI->connect(
        'dbi:SQLite:dbname=t/test.db',
        {
            RaiseError => 1,
            AutoCommit => 1,
        });
    
    $dbh->do( <<SQL );
CREATE TABLE master (
  id             INTEGER PRIMARY KEY NOT NULL,
  text_col       TEXT,
  password_col   TEXT,
  checkbox_col   BOOLEAN DEFAULT 1,
  select_col     TEXT,
  combobox_col   TEXT,
  radio_col      TEXT,
  radiogroup_col TEXT,
  date_col       DATETIME,
  type_id        INTEGER,
  type2_id       INTEGER,
  not_in_form    TEXT
);

SQL


    $dbh->do( <<SQL );
CREATE TABLE note (
  id     INTEGER PRIMARY KEY NOT NULL,
  master INTEGER NOT NULL,
  note   TEXT NOT NULL
);

SQL


    $dbh->do( <<SQL );
CREATE TABLE user (
  id     INTEGER PRIMARY KEY NOT NULL,
  master INTEGER NOT NULL,
  name   TEXT NOT NULL,
  title  TEXT
);

SQL


    $dbh->do( <<SQL );
CREATE TABLE band (
  id   INTEGER PRIMARY KEY NOT NULL,
  band TEXT NOT NULL
);

SQL


    $dbh->do( <<SQL );
CREATE TABLE user_band (
  user INTEGER NOT NULL,
  band INTEGER NOT NULL,
  PRIMARY KEY (user, band)
);

SQL


    $dbh->do( <<SQL );
CREATE TABLE address (
  id       INTEGER PRIMARY KEY NOT NULL,
  user     INTEGER NOT NULL,
  my_label TEXT,
  address  TEXT NOT NULL
);

SQL


    $dbh->do( <<SQL );
CREATE TABLE type (
  id   INTEGER PRIMARY KEY NOT NULL,
  type TEXT NOT NULL
);

SQL

    $dbh->do(" INSERT INTO type VALUES (1,'foo')" );;
    $dbh->do(" INSERT INTO type VALUES (2,'bar')" );


    $dbh->do( <<SQL );
CREATE TABLE type2 (
  id   INTEGER PRIMARY KEY NOT NULL,
  type TEXT NOT NULL
);

SQL

    $dbh->do("INSERT INTO type2 VALUES (1,'foo')" );
    $dbh->do("INSERT INTO type2 VALUES (2,'bar')" );


    $dbh->do( <<SQL );
CREATE TABLE has_many (
  user  INTEGER NOT NULL,
  key   TEXT NOT NULL,
  value TEXT NOT NULL,
  PRIMARY KEY (user, key)
);

SQL

    $dbh->do( <<SQL );
CREATE TABLE schedule (
  id     INTEGER PRIMARY KEY NOT NULL,
  master INTEGER NOT NULL,
  date   DATETIME NOT NULL,
  note   TEXT NOT NULL
);

SQL

}


1;
