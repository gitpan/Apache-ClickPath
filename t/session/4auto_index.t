use strict;

use Apache::Test qw(:withtestmore);
use Test::More;
use Apache::TestUtil;
use Apache::TestRequest 'GET_BODY';

plan tests => 6;

Apache::TestRequest::module('default');

my $config   = Apache::Test::config();
my $hostport = Apache::TestRequest::hostport($config) || '';
t_debug("connecting to $hostport");

my $got=GET_BODY( "/tmp/", redirect_ok=>0 );
ok( t_cmp( $got, qr!<a href="/-S:\S+/">! ), "/tmp/ -- parent directory w/o session" );
ok( t_cmp( $got, qr!<a href="/-S:\S+/tmp/x\.html">! ), "/tmp/ -- x.html w/o session" );

$got=~m!<a href="(/-S:\S+)/tmp/x\.html">!;
my $session=$1;

$got=GET_BODY( "$session/tmp/", redirect_ok=>0 );
ok( t_cmp( $got, qr!<a href="\Q$session\E/">! ), "/tmp/ -- parent directory w/ session" );
ok( t_cmp( $got, qr!<a href="x\.html">! ), "/tmp/ -- x.html w/ session" );

sleep 5;

$got=GET_BODY( "$session/tmp/", redirect_ok=>0 );
ok( t_cmp( $got, qr!<a href="\Q$session\E/">! ), "/tmp/ -- parent directory w/ expired session" );
ok( t_cmp( $got, qr!<a href="x\.html">! ), "/tmp/ -- x.html w/ expired session" );

# Local Variables: #
# mode: cperl #
# End: #
