package TestSession::2output_headers;

use strict;
use Apache::RequestRec ();
use Apache::RequestIO ();
use Apache::Const -compile => qw(OK REDIRECT);

sub handler {
  my $r=shift;

  my %args=map {
    tr/+/ /;
    s/%([0-9a-fA-F]{2})/pack("C",hex($1))/ge;
    $_;
  } split /[=&;]/, $r->args, -1;

  $r->content_type($args{type});
  if( exists $args{rc} and $args{rc}!=200 ) {
    $r->err_headers_out->set(Location=>$args{loc}) if( exists $args{loc} );
    $r->err_headers_out->set(Refresh=>$args{refresh}) if( exists $args{refresh} );
  } else {
    $r->headers_out->set(Location=>$args{loc}) if( exists $args{loc} );
    $r->headers_out->set(Refresh=>$args{refresh}) if( exists $args{refresh} );
  }
  $r->print( $r->args );

  if( exists $args{rc} ) {
    return $r->status( $args{rc} );
  } else {
    return Apache::OK;
  }
}

1;

__DATA__

SetHandler modperl
PerlResponseHandler TestSession::2output_headers
