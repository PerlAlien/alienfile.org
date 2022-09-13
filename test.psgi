#!/usr/bin/env perl
# warning, this file is generated
use strict;
use warnings;
use Plack::Builder;
use Plack::App::GitHubPages::Faux;
builder {
  enable "XOR::NoCache";
  Plack::App::GitHubPages::Faux->new( root => "docs" )->to_app;
};