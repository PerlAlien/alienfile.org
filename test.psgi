#!/usr/bin/env perl

use strict;
use warnings;
use 5.026;
use Plack::Builder;
use Path::Tiny qw( path );
use Plack::App::XOR;

my $docs = path(__FILE__)->sibling('docs')->absolute;
builder {
  enable "XOR::DirIndex", root => $docs;
  enable "XOR::NoCache";
  Plack::App::XOR->new(root => $docs)->to_app;
};
