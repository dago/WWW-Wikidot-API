#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'WWW::Wikidot::API' ) || print "Bail out!\n";
}

diag( "Testing WWW::Wikidot::API $WWW::Wikidot::API::VERSION, Perl $], $^X" );
