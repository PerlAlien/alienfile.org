package Plack::Middleware::XOR::NoCache {

  use strict;
  use warnings;
  use 5.026;
  use experimental qw( signatures );
  use parent qw( Plack::Middleware );

  sub call ($self, $env)
  {
    my $res = $self->app->($env);
    push $res->[1]->@*, 'cache-control' => 'no-cache';
    return $res;
  }
}

1;
