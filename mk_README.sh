#!/bin/bash

(perldoc -tU ./lib/Apache/ClickPath.pm
 perldoc -tU $0
) >README

exit 0

=head1 INSTALLATION

 perl Makefile.PL
 make
 make test
 make install

=head1 DEPENDENCIES

mod_perl 1.9918 (aka 2.0.0-RC1),
perl 5.8.0

=cut