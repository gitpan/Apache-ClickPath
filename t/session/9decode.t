use strict;

use Test::More tests=>27;

BEGIN {use_ok( 'Apache::ClickPath::Decode' );}

my $s1='PtVOR9:dxAredNNqtcus9NNNOdM';
my $s2='6r56:dxAredNNqtcus9NNNOdM';
my $s3='s9NNNd:dxCuJtNNbBHExdNNNNNMsMyq*.CF!vq*.InoJ';

my $decoder=Apache::ClickPath::Decode->new;

$decoder->parse( $s1 );

ok $decoder->server_id eq '10.2.1.19', 'server_id';
ok $decoder->creation_time eq '1112350277', 'creation_time';
ok $decoder->server_pid eq '30211', 'server_pid';
ok $decoder->connection_id eq '20', 'connection_id';
ok $decoder->seq_number eq '57727', 'seq_number';

$decoder->tag='-S:';

$decoder->parse( 'http://localhost/-S:'.$s1.'/bla' );

ok $decoder->server_id eq '10.2.1.19', 'server_id (w/ tag)';
ok $decoder->creation_time eq '1112350277', 'creation_time (w/ tag)';
ok $decoder->server_pid eq '30211', 'server_pid (w/ tag)';
ok $decoder->connection_id eq '20', 'connection_id (w/ tag)';
ok $decoder->seq_number eq '57727', 'seq_number (w/ tag)';
ok $decoder->session eq $s1, 'session (w/ tag)';

$decoder->server_map='';

$decoder->parse( 'http://localhost/-S:'.$s2.'/bla' );

ok $decoder->server_id eq 'test', 'server_id (w/ server_map)';
ok $decoder->creation_time eq '1112350277', 'creation_time (w/ server_map)';
ok $decoder->server_pid eq '30211', 'server_pid (w/ server_map)';
ok $decoder->connection_id eq '20', 'connection_id (w/ server_map)';
ok $decoder->seq_number eq '57727', 'seq_number (w/ server_map)';

undef $decoder->server_map;
$decoder->parse( 'http://localhost/-S:'.$s3.'/bla' );

ok $decoder->server_id eq '127.0.0.1', 'server_id (s3)';
ok $decoder->creation_time eq '1112383990', 'creation_time (s3)';
ok $decoder->server_pid eq '15198', 'server_pid (s3)';
ok $decoder->connection_id eq '0', 'connection_id (s3)';
ok $decoder->seq_number eq '63633', 'seq_number (s3)';
ok !defined( $decoder->remote_session ), 'remote_session (s3)';
ok !defined( $decoder->remote_session_host ), 'remote_session_host (s3)';

$decoder->friendly_session=<<'FRIENDLY';
  param.friendly.org   param(ld) param ( id )   f
  uri.friendly.org     uri(1) uri ( 3 )         u
  mixed.friendly.org    param(ld) uri ( 3 )     m
FRIENDLY

$decoder->parse( 'http://localhost/-S:'.$s3.'/bla' );
ok $decoder->session eq $s3, 'session (s3 w/ friendly_session)';
ok $decoder->remote_session eq "ld=25\nid=8ab9", 'remote_session (s3 w/ friendly_session)';
ok $decoder->remote_session_host eq 'param.friendly.org', 'remote_session_host (s3 w/ friendly_session)';

# Local Variables: #
# mode: cperl #
# End: #
