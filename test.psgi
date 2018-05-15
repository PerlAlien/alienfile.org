#!/usr/bin/env perl

use strict;
use warnings;
use 5.026;
use Plack::Builder;
use Path::Tiny qw( path );

my $docs = path(__FILE__)->sibling('docs');

package Plack::App::File::Custom {

  use base 'Plack::App::File';
  
  sub return_404
  {
    my($self) = @_;
    my $file = $docs->child('404.html');
    return $self->SUPER::return_404 unless -f $file;
    my $not_found_html = $file->slurp;
    [
      404, 
      [ 'Content-Type' => 'text/html', 'Content-Length' => length $not_found_html ], 
      [ $not_found_html ],
    ];
  }

}

builder {
  enable "DirIndex", dir_index => 'index.html';
  Plack::App::File::Custom->new(root => "$docs")->to_app;
};
