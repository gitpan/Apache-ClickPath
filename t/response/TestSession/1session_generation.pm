package TestSession::1session_generation;

use strict;
use Apache::RequestRec ();
use Apache::RequestIO ();
use Apache::Const -compile => qw(OK);

sub handler {
  my $r=shift;

  my $what=$r->args;
  $r->content_type('text/plain');
  $r->print( $what."=".$r->subprocess_env($what)."\n" );

  return Apache::OK;
}

1;

__DATA__

SetHandler modperl
PerlResponseHandler TestSession::1session_generation
