package Apache::ClickPath::_parse;

use strict;

sub UAExceptions {
  my $conf=shift;
  my $a=[];
  foreach my $line (split /\r?\n/, $conf) {
    if( $line=~/^\s*(\w+):?\s+(.+?)\s*$/ ) {
      push @{$a}, [$1, qr/$2/];
    }
  }
  return $a;
}

sub FriendlySessions {
  my $conf=shift;
  my $t={};
  my $r={};

  foreach my $l (split /\r?\n/, $conf) {

    next unless( $l=~/^\s*(\S+)\s+	# $1: friendly REMOTE_HOST
                      (			# $2: list of "uri( number )" or
                       (?:		#     "param( name )" statements
		        (?:uri|param)\s*
		        \(
		          \s*\w+\s*
                        \)\s*
                       )+
                      )
                      (?:\s*(\w+))?	# $3: opt. name, default=REMOTE_HOST
                     /x );

    my ($rem_host, $stmt_list, $name)=($1, $2, $3);
    $name=$rem_host unless( defined $name );

    my @stmts;
    while( $stmt_list=~/(uri|param)\s*\(\s*(\w+)\s*\)/g ) {
      push @stmts, [$1, $2];
    }

    $t->{$rem_host}=[[@stmts], $name];
    $r->{$name}=$rem_host;
  }

  return $t, $r;
}

1;
