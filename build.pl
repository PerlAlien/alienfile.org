#!/usr/bin/env perl

use strict;
use warnings;
use XOR;

my $xor = XOR->new(
  root => '.',
  org  => 'PerlAlien',
  site_name => 'alienfile.org',
);

$xor->pods->add_sister_site("https://uperl.github.io");
$xor->pods->add_sister_site("https://perlwasm.github.io");
$xor->pods->add_sister_site("https://pl.atypus.org");

$xor->builder->build;
