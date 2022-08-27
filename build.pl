#!/usr/bin/env perl

use strict;
use warnings;
use lib 'lib';
use XOR;

my $xor = XOR->new( root => '.' );
$xor->builder->build;
