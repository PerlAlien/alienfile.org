#!/usr/bin/env perl

use strict;
use warnings;
use 5.026;
use Plack::App::File;
use Plack::Builder;
use Path::Tiny qw( path );

my $docs = path(__FILE__)->sibling('docs');

builder {
  enable "DirIndex", dir_index => 'index.html';
  Plack::App::File->new(root => "$docs")->to_app;
};
