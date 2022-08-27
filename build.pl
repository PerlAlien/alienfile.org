#!/usr/bin/env perl

use strict;
use warnings;
use XOR;

my $xor = XOR->new(
  root => '.',
  org  => 'PerlAlien',
  site_name => 'alienfile.org',
);
$xor->builder->build;
