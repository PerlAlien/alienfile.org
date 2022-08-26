#!/usr/bin/env perl

use strict;
use warnings;
use lib 'lib';
use 5.026;
use experimental qw( signatures );
use JSON::MaybeXS qw( decode_json );
use Path::Tiny qw( path );
use Web;

my %repos;

my $page = 1;
while(1)
{
  my $res = Web->ua->get("https://api.github.com/orgs/PerlAlien/repos?page=$page");
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
        my $set = Web->mcpan->release({ all => [ { distribution => $name }, { status => 'latest' } ] });
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

path(__FILE__)->parent->child('.tarballs.txt')->spew(join("\n", sort values %repos));
