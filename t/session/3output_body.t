use strict;

use Apache::Test qw(:withtestmore);
use Test::More;
use Apache::TestUtil;
use Apache::TestRequest 'GET_BODY';

plan tests => 28;

Apache::TestRequest::module('default');

my $config   = Apache::Test::config();
my $hostport = Apache::TestRequest::hostport($config) || '';
t_debug("connecting to $hostport");

mkdir "t/htdocs/tmp";
open F, ">t/htdocs/tmp/x.html" and print F <<"EOF";
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>output_body</title>
    <meta http-equiv="refresh" content="10; URL=/index1.html">
    <meta http-equiv=refresh content=10;URL=/index2.html>
    <meta content="10; URL=/index3.html" http-equiv="refresh">
    <meta content="10; URL=http://$hostport/index4.html" http-equiv="refresh">
    <meta content="10; URL=../index5.html" http-equiv="refresh">
    <meta content="10; URL=http://x.y/index5.html" http-equiv="refresh">
  </head>

  <body>
    <a href="/index1.html">1</a>
    <a href="http://$hostport/index1.html">2</a>
    <a href="../index1.html">3</a>
    <a href="http://x.y/index1.html">4</a>
    <form action="/index1.html">1</form>
    <form action="http://$hostport/index1.html">2</form>
    <form action="../index1.html">3</form>
    <form action="http://x.y/index1.html">4</form>
  </body>
</html>
EOF
close F;

my $got=GET_BODY( "/tmp/x.html", redirect_ok=>0 );
ok( t_cmp( $got, qr!<meta http-equiv="refresh" content="10; URL=/-S:\S+/index1\.html">! ),
    "meta 1" );
ok( t_cmp( $got, qr!<meta http-equiv=refresh content=10;URL=/index2\.html>! ),
    "meta 2" );
ok( t_cmp( $got, qr!<meta content="10; URL=/-S:\S+/index3\.html" http-equiv="refresh">! ),
    "meta 3" );
ok( t_cmp( $got, qr!<meta content="10; URL=http://\Q$hostport\E/-S:\S+/index4\.html" http-equiv="refresh">! ),
    "meta 4" );
ok( t_cmp( $got, qr!<meta content="10; URL=/-S:\S+/tmp/\.\./index5\.html" http-equiv="refresh">! ),
    "meta 5" );
ok( t_cmp( $got, qr!<meta content="10; URL=http://x\.y/index5\.html" http-equiv="refresh">! ),
    "meta 6" );

ok( t_cmp( $got, qr!<a href="/-S:\S+/index1\.html">1</a>! ),
    "a 1" );
ok( t_cmp( $got, qr!<a href="http://\Q$hostport\E/-S:\S+/index1\.html">2</a>! ),
    "a 2" );
ok( t_cmp( $got, qr!<a href="/-S:\S+/tmp/\.\./index1\.html">3</a>! ),
    "a 3" );
ok( t_cmp( $got, qr!<a href="http://x\.y/index1\.html">4</a>! ),
    "a 4" );

ok( t_cmp( $got, qr!<form action="/-S:\S+/index1\.html">1</form>! ),
    "form 1" );
ok( t_cmp( $got, qr!<form action="http://\Q$hostport\E/-S:\S+/index1\.html">2</form>! ),
    "form 2" );
ok( t_cmp( $got, qr!<form action="/-S:\S+/tmp/\.\./index1\.html">3</form>! ),
    "form 3" );
ok( t_cmp( $got, qr!<form action="http://x.y/index1.html">4</form>! ),
    "form 4" );

my $session=GET_BODY( "/TestSession__1session_generation?CGI_SESSION" );
$session=~s/^.*?=//;

$got=GET_BODY( "$session/tmp/x.html", redirect_ok=>0 );
ok( t_cmp( $got, qr!<meta http-equiv="refresh" content="10; URL=\Q$session\E/index1\.html">! ),
    "meta 1" );
ok( t_cmp( $got, qr!<meta http-equiv=refresh content=10;URL=/index2\.html>! ),
    "meta 2" );
ok( t_cmp( $got, qr!<meta content="10; URL=\Q$session\E/index3\.html" http-equiv="refresh">! ),
    "meta 3" );
ok( t_cmp( $got, qr!<meta content="10; URL=http://\Q$hostport$session\E/index4\.html" http-equiv="refresh">! ),
    "meta 4" );
ok( t_cmp( $got, qr!<meta content="10; URL=\.\./index5\.html" http-equiv="refresh">! ),
    "meta 5" );
ok( t_cmp( $got, qr!<meta content="10; URL=http://x\.y/index5\.html" http-equiv="refresh">! ),
    "meta 6" );

ok( t_cmp( $got, qr!<a href="\Q$session\E/index1\.html">1</a>! ),
    "a 1" );
ok( t_cmp( $got, qr!<a href="http://\Q$hostport$session\E/index1\.html">2</a>! ),
    "a 2" );
ok( t_cmp( $got, qr!<a href="\.\./index1\.html">3</a>! ),
    "a 3" );
ok( t_cmp( $got, qr!<a href="http://x\.y/index1\.html">4</a>! ),
    "a 4" );

ok( t_cmp( $got, qr!<form action="\Q$session\E/index1\.html">1</form>! ),
    "form 1" );
ok( t_cmp( $got, qr!<form action="http://\Q$hostport$session\E/index1\.html">2</form>! ),
    "form 2" );
ok( t_cmp( $got, qr!<form action="\.\./index1\.html">3</form>! ),
    "form 3" );
ok( t_cmp( $got, qr!<form action="http://x.y/index1.html">4</form>! ),
    "form 4" );

# Local Variables: #
# mode: cperl #
# End: #
