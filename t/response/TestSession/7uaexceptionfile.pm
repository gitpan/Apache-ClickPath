package TestSession::7uaexceptionfile;

use strict;
use Apache::RequestRec ();
use Apache::RequestIO ();
use Apache::Const -compile => qw(OK);

sub handler {
  my $r=shift;

  my $what=$r->args;
  $what="UAExceptions" unless( length $what );
  $r->content_type('text/plain');
  $r->print( Apache::Module::get_config
	     ('Apache::ClickPath', $r->server, $r->per_dir_config)
	     ->{"ClickPath${what}File_read_time"} );

  return Apache::OK;
}

1;

__DATA__

SetHandler modperl
PerlResponseHandler TestSession::7uaexceptionfile
