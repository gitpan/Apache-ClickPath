#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use Pod::Usage;
use Config;
use File::Spec;
use FindBin;

use warnings;
use Apache::ClickPath::Decode ();

sub main {
  my ($help, $man);

  my $decoder=Apache::ClickPath::Decode->new;

  if( !GetOptions(
		  'tag=s'=>sub {$decoder->tag=$_[1]},
		  'friendly_session=s'=>sub {
		    local $/;
		    my $f=$_[1];
		    open my $fh, $f or die "ERROR: Cannot open $f: $!\n";
		    $decoder->friendly_session=scalar( <$fh> );
		    close $fh;
		  },
		  'server_map:s'=>sub {$decoder->server_map=$_[1]},
		  help=>\$help,
		  manual=>\$man,
		 ) ||
      $help ) {
    pod2usage(-exitval=>1, -verbose=>1);
  }

  if( $man ) {
    my $progpath = File::Spec->catfile($Config{bin}, "perldoc");
    exec( $progpath, '-U',
	  File::Spec->catfile($FindBin::RealBin, $FindBin::RealScript) );
  }

  foreach my $s (@ARGV) {
    $decoder->parse( $s );
    print "Session: ".$decoder->session."\n";
    print "  Creation Time: ".localtime( $decoder->creation_time )." (".$decoder->creation_time.")\n";
    print "  Server ID: ".$decoder->server_id."\n";
    print "  Server PID: ".$decoder->server_pid."\n";
    print "  Connection ID: ".$decoder->connection_id."\n";
    print "  Seq. #: ".$decoder->seq_number."\n";
    if( $decoder->remote_session ) {
      print "  Remote Session: ".$decoder->remote_session."\n";
      print "  Remote Session Host: ".$decoder->remote_session_host."\n";
    }
  }
}

exit main;

__END__

=head1 NAME

decode-session.pl - decodes Apache::ClickPath session identifiers

=head1 SYNOPSIS

 decode-session.pl [OPTIONS] session1 [... sessionN]

=head1 DESCRIPTION

C<decode-session.pl> decodes an C<Apache::ClickPath> session using
C<Apache::ClickPath::Decode>. See the L<Apache::ClickPath::Decode(3)>
manpage.

=head1 OPTIONS

=over 4

=item B<--tag TAG>

=item B<--friendly_sessions FILENAME>

=item B<--server_map [FILENAME]>

See the L<Apache::ClickPath::Decode(3)> manpage for more information.
The C<FILENAME> argument to the C<--server_map> option is optional.
Currently calling it with a C<--server_map> argument other than an
empty string is not supported and gives a warning.

=back

=head1 AUTHOR

Torsten Foertsch, E<lt>torsten.foertsch@gmx.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Torsten Foertsch

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut
