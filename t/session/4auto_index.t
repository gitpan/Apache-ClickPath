use strict;

use Apache::Test qw(:withtestmore);
use Test::More;
use Apache::TestUtil;
use Apache::TestRequest 'GET_BODY';

plan tests => 4;

Apache::TestRequest::module('default');

my $config   = Apache::Test::config();
my $hostport = Apache::TestRequest::hostport($config) || '';
t_debug("connecting to $hostport");

my $got=GET_BODY( "/tmp/", redirect_ok=>0 );
ok( t_cmp( $got, qr!<a href="/-S:\S+/">! ), "/tmp/ -- parent directory" );
ok( t_cmp( $got, qr!<a href="/-S:\S+/tmp/x\.html">! ), "/tmp/ -- x.html" );

$got=~m!<a href="(/-S:\S+)/tmp/x\.html">!;
my $session=$1;

$got=GET_BODY( "$session/tmp/", redirect_ok=>0 );
ok( t_cmp( $got, qr!<a href="\Q$session\E/">! ), "/tmp/ -- parent directory" );
ok( t_cmp( $got, qr!<a href="x\.html">! ), "/tmp/ -- x.html" );

# Local Variables: #
# mode: cperl #
# End: #
