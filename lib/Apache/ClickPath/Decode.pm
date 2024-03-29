package Apache::ClickPath::Decode;

use strict;
use warnings;
no warnings qw{uninitialized};
use Apache::ClickPath::_parse;
use MIME::Base64 ();
use Class::Member qw{friendly_session
		     tag
		     server_map
		     session
		     remote_session_host remote_session
		     server_id
		     creation_time
		     server_pid
		     seq_number
		     connection_id};

our $VERSION='1.2';

sub new {
  my $class=shift;
  my $I={};
  my %o=@_;

  if( ref( $class ) ) {
    bless $I=>ref( $class );
    $I->friendly_session=$class->friendly_session;
    $I->tag=$class->tag;
    $I->server_map=$class->server_map;
  } else {
    bless $I=>$class;
  }

  foreach my $m (qw{friendly_session tag server_map session}) {
    $I->$m=$o{$m} if( exists $o{$m} );
  }

  if( length $I->session ) {
    return $I->parse;
  }

  return $I;
}

sub parse {
  my $I=shift;
  $I->session=shift if( @_ );

  my $session=$I->session;

  if( length $I->tag ) {
    my $tag=$I->tag;
    return unless( $session=~m~\Q$tag\E([^/]+)~ );
    $I->session=$session=$1;
  }

  return unless( length $session );

  if( defined $I->friendly_session and ref($I->friendly_session) ne 'HASH' ) {
    (undef, $I->friendly_session)=Apache::ClickPath::_parse::FriendlySessions
      ( $I->friendly_session );
  }

  # decode session
  $session=~tr[N-Za-z0-9@\-,A-M][A-Za-z0-9@\-,];
  my @l=split /,/, $session, 3;

  # extract remote session
  if( @l==3 and
      defined $I->friendly_session and
      exists $I->friendly_session->{$l[1]} ) {
    my %h=('**'=>'*', '*!'=>'!', '*.'=>'=', '!'=>"\n");
    $l[2]=~s/(\*[*!.]|!)/$h{$1}/ge;

    $I->remote_session_host=$I->friendly_session->{$l[1]};
    $I->remote_session=$l[2];
  } else {
    undef $I->remote_session_host;
    undef $I->remote_session;
  }

  # extract session start time
  $l[0]=~tr[@\-][+/];
  @l=split /:/, $l[0], 2;	# $l[0]: IP Addr, $l[1]: session

  return unless( @l==2 );

  if( defined $I->server_map ) {
    if( length $I->server_map ) {
      warn "WARNING: ".__PACKAGE__.": server_map( FILENAME ) not implemented yet.\n";
      $I->server_id=$l[0];
    } else {
      $I->server_id=$l[0];
    }
  } else {
    my $len4=do {use integer; (length( $l[0] )+3)/4;};
    $len4*=4;
    $I->server_id=
      join( '.',
	    unpack("C*",
		   MIME::Base64::decode_base64($l[0].
					       ('='x($len4-length( $l[0] ))))) );
  }

  my $len4=do {use integer; (length( $l[1] )+3)/4;};
  $len4*=4;
  ($I->creation_time,
   $I->server_pid,
   $I->seq_number,
   $I->connection_id)=
     unpack( "NNnNn",
	     MIME::Base64::decode_base64( $l[1].
					  ('='x($len4-length( $l[1] ))) ) );

  return $I;
}

1;

__END__

=head1 NAME

Apache::ClickPath::Decode - Decode Apache::ClickPath session IDs

=head1 SYNOPSIS

 use Apache::ClickPath::Decode;
 my $decoder=Apache::ClickPath::Decode->new;
 $decoder->tag='-';
 my $time=$decoder
             ->parse( 'http://bla.com/-PtVOR9:dxAredNNqtcus9NNNOdM/' )
             ->creation_time;

=head1 DESCRIPTION

C<Apache::ClickPath::Decode> provides an OO interface for decoding
C<Apache::ClickPath> session identifiers.

=head2 Methods

This module uses L<Class::Member(3)> to implement member functions. Thus,
all member functions are lvalues, eg C<< $decoder->tag='-' >>.

=over 4

=item B<new>

The constructor. If called as instance method it creates a new instance that
inherits the C<friendly_session>, C<tag> and C<server_map> attributes if they
are not overridden be parameters.

C<new()> accepts named parameters as C<< NAME => VALUE >> pairs. The following
parameters are recognized:

=over 2

=item B<friendly_session>

=item B<tag>

=item B<server_map>

for these 3 see the appropriate member functions below.

=item B<session>

if a session is given, C<parse()> is called immediately. So, the result is
directly accessible.

=back

=item B<parse>

C<parse()> is called with an optional parameter containing the actual session
identifier. If ommitted the internally stored session identifier is used.

If the object's C<tag> attribute is set the session can actually contain an
URL or an arbitrary string containing a session identifier that is preceded
with the tag and ended with a slash (/). After parsing the C<session> member
function returns the found session without surrounding characters.

After C<parse> the session information can be fetched by C<creation_time>
C<server_pid>, C<seq_number>, C<connection_id>, C<remote_session>,
C<remote_session_host> and C<server_id> member functions.

If the C<friendly_session> attribute is given and the session contains a
friendly session then the C<remote_session> and C<remote_session_host>
member functions will return the remote session.

If the C<server_map> attribute is set the C<server_id> member function will
return the machine's name according to the C<Apache::ClickPaths>'s
C<ClickPathMachine> directive. Currently this attribute must be assigned
an emtpy string or left undefined. Otherwize a warning is issued.
If defined the sessions server-id part is directly assigned to C<server_id>.
If not defined it indicates that the C<ClickPathMachine> directive was not
given in your C<httpd.conf> and the server-id is to be interpreted as IP
address.

C<parse> returns the object itself on success or C<undef>.

=back

=head2 Member Functions

=over 4

=item B<tag>

this member function matches C<Apache::ClickPath>'s C<ClickPathSessionPrefix>
directive. If given the module can identify session identifiers in URLs.
So, C<parse()> can be called directly with an URL. If not given the whole
string passed to C<parse()> is tried as session identifier.

=item B<friendly_session>

this matches C<Apache::ClickPath>'s C<ClickPathFriendlySessions> container
directive. It can be set to a string consiting of lines each describing
a friendly session as the directive in your C<httpd.conf> does.

=item B<server_map>

if left undefined C<parse()> will interpret the server-id part
of a session identifier as IP address. If set to an empty string it will
not. In a future version of C<Apache::ClickPath> I plan to provide
directives to give a table of (IP adress, machine name) pairs in the
C<httpd.conf>. Then all machines of a cluster can run with the same
configuration files. Then the decoder will also be extented to map these
names back and this attribute will be allowed to be assigned a non-empty
string, too.

=item B<session>

is initialized with a session identifier or an URL. After C<parse()> is
called it contains the session identifier.

=item B<remote_session>

=item B<remote_session_host>

=item B<server_id>

=item B<creation_time>

=item B<server_pid>

=item B<seq_number>

=item B<connection_id>

These members are initialized be C<parse()> to hold the components of the
parsed session. For the first 3 see C<parse()> above and
L<Apache::ClickPath(3)>. C<creation_time> returns the sessions creation time
in seconds since 1/1/1970 00:00 GMT, C<server_pid> the WEB server's process
id, C<seq_number> a 16-bit number that is incremented for each new session
a WEB server process creates. At process start up is is initialized with a
random number. So it does not indicate how much sessions a server process
has created. C<connection_id> contains the Apache's connection ID. Refer to
Apache's source code an docs for more information.

=back

=head1 SEE ALSO

L<Apache::ClickPath(3)>,
L<http://httpd.apache.org>

=head1 AUTHOR

Torsten Foertsch, E<lt>torsten.foertsch@gmx.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Torsten Foertsch

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut
