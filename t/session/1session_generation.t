use strict;

use Apache::Test qw(:withtestmore);
use Test::More;
use Apache::TestUtil;
use Apache::TestRequest 'GET_BODY';

plan tests => 11;

Apache::TestRequest::module('default');

my $config   = Apache::Test::config();
my $hostport = Apache::TestRequest::hostport($config) || '';
t_debug("connecting to $hostport");

ok t_cmp( GET_BODY( "/TestSession__1session_generation?SESSION" ),
	  qr/^SESSION=.+/m,  ), "SESSION exists";

ok t_cmp( GET_BODY( "/TestSession__1session_generation?CGI_SESSION" ),
	  qr/^CGI_SESSION=.+/m ), "CGI_SESSION exists";

ok t_cmp( GET_BODY( "/TestSession__1session_generation?SESSION_AGE" ),
	  qr/^SESSION_AGE=0$/m ), "SESSION_AGE=0";

my $start=GET_BODY( "/TestSession__1session_generation?SESSION_START" );
my $time=time;
ok $start=~/^SESSION_START=(\d+)$/ && $time-2<=$1 && $1<=$time,
   "SESSION_START range check";

my $session=GET_BODY( "/TestSession__1session_generation?CGI_SESSION" );
chomp $session;
ok( ($session=~s/^CGI_SESSION=//) &&
    do { sleep 2;
	 t_debug("getting $session/TestSession__1session_generation?SESSION_AGE");
	 my $age=GET_BODY( "$session/TestSession__1session_generation?SESSION_AGE" );
	 ($age=~/^SESSION_AGE=(\d+)/) and 2<=$1 and $1<=3;
       },
    'SESSION_AGE>0' );

ok( do { sleep 5;
	 t_debug("getting $session/TestSession__1session_generation?SESSION_AGE");
	 my $age=GET_BODY( "$session/TestSession__1session_generation?SESSION_AGE" );
	 ($age=~/^SESSION_AGE=0$/);
       },
    'MaxSessionAge hit' );

Apache::TestRequest::module('Machine');

$config   = Apache::Test::config();
$hostport = Apache::TestRequest::hostport($config) || '';
t_debug("connecting to $hostport");

$session=GET_BODY( "/TestSession__1session_generation?CGI_SESSION" );
chomp $session;
ok $session=~s/^CGI_SESSION=// && t_cmp( $session, qr!^/-S:6r56:.+!m ),
   "ClickPathMachine directive at work";

ok t_cmp( GET_BODY( "$session/TestSession__1session_generation?CGI_SESSION" ),
	  qr/^CGI_SESSION=$session/m ), "ClickPathMachine directive at work 2";

Apache::TestRequest::module('NullMachine');

$config   = Apache::Test::config();
$hostport = Apache::TestRequest::hostport($config) || '';
t_debug("connecting to $hostport");

$session=GET_BODY( "/TestSession__1session_generation?CGI_SESSION" );
chomp $session;
ok $session=~s/^CGI_SESSION=// && t_cmp( $session, qr!^/-S::.+!m ),
   "empty ClickPathMachine directive at work";

ok t_cmp( GET_BODY( "$session/TestSession__1session_generation?CGI_SESSION" ),
	  qr/^CGI_SESSION=$session/m ),
   "empty ClickPathMachine directive at work 2";

Apache::TestRequest::module('Without_UAExc');

$config   = Apache::Test::config();
$hostport = Apache::TestRequest::hostport($config) || '';
t_debug("connecting to $hostport");

ok t_cmp( GET_BODY( "/TestSession__1session_generation?SESSION" ),
	  qr/^SESSION=.+/m,  ), "SESSION exists";

# Local Variables: #
# mode: cperl #
# End: #