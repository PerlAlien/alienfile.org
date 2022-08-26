#!/usr/bin/env perl

use strict;
use warnings;
use 5.026;
use experimental qw( signatures );
use HTTP::Tiny;
use JSON::MaybeXS qw( decode_json );
use CHI;
use WWW::Mechanize::Cached;
use HTTP::Tiny::Mech;
use MetaCPAN::Client;
use Path::Tiny qw( path );

my $ht = HTTP::Tiny->new(
  default_headers => {
    Authorization => "token $ENV{GITHUB_OAUTH_TOKEN}",
  }
);

my $mcpan = MetaCPAN::Client->new(
  ua => HTTP::Tiny::Mech->new(
    mechua => WWW::Mechanize::Cached->new(
      cache => CHI->new(
        driver   => 'File',
        root_dir => '/tmp/metacpan-cache',
      ),
    ),
  ),
);

my %repos;

my $page = 1;
while(1)
{
  my $res = $ht->get("https://api.github.com/orgs/PerlAlien/repos?page=$page");
  if($res->{success})
  {
    $res = decode_json($res->{content});
    if(@$res > 0)
    {
      foreach my $repo (@$res)
      {
        next if $repo->{archived};
        my $name = $repo->{name};
        next if $name =~ /^(dontpanic|autotools-libpalindrome|cmake-libpalindrome|alienfile.org|hunspell)$/;
        my $set = $mcpan->release({ all => [ { distribution => $name }, { status => 'latest' } ] });
        die "latest release for $name returned @{[ $set->total ]} items" if $set->total != 1;
        my $release = $set->next;
        $repos{$name} = $release->download_url;
      }
      $page++;
    }
    else
    {
      last;
    }
  }
  else
  {
      die "error fetching repository list @{[ $res->{status} ]} @{[ $res->{reason} ]}";
  }
}

path('tarballs.txt')->spew(join("\n", sort values %repos));
