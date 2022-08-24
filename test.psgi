#!/usr/bin/env perl

use strict;
use warnings;
use 5.026;
use experimental qw( signatures );
use Plack::Builder;
use Path::Tiny qw( path );

my $docs = path(__FILE__)->sibling('docs')->absolute;

package Plack::Middleware::DirIndex {

  $INC{'Plack/Middleware/DirIndex.pm'} = __FILE__;

  use parent qw( Plack::Middleware );

  sub call ($self, $env)
  {
    warn "PATH_INFO = @{[ $env->{PATH_INFO} ]}";
    if($env->{PATH_INFO} =~ m{/$})
    {
      if(-f $docs->child($env->{PATH_INFO}, 'index.html'))
      {
        $env->{PATH_INFO} .= "index.html";
        warn "new PATH_INFO = @{[ $env->{PATH_INFO} ]}";
      }
    }
    else
    {
      if(-d $docs->child($env->{PATH_INFO}))
      {
        return [
          301,
          [ Location => "@{[ $env->{PATH_INFO} ]}/" ],
          [ '' ],
        ];
      }
    }

    my $res = $self->app->($env);
    push $res->[1]->@*, 'cache-control' => 'no-cache';
    return $res;
  }
}

package Plack::App::File::Custom {

  use base 'Plack::App::File';
  
  sub return_404 ($self)
  {
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
  enable "DirIndex", dir_index => 'index.html', root => "$docs";
  Plack::App::File::Custom->new(root => "$docs")->to_app;
};
