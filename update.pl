#!/usr/bin/env perl

use strict;
use warnings;
use lib 'lib';
use 5.026;
use experimental qw( signatures );
use JSON::MaybeXS qw( decode_json );
use Path::Tiny qw( path );
use XOR::Web;

my %repos;
my $web = XOR::Web->new;

for(my $page = 1; 1; $page++)
{
  my $res = decode_json($web->get("https://api.github.com/orgs/PerlAlien/repos?page=$page"));

  last unless @$res > 0;

  foreach my $repo (@$res)
  {
    next if $repo->{archived};
    my $name = $repo->{name};
    next if $name =~ /^(dontpanic|autotools-libpalindrome|cmake-libpalindrome|alienfile.org|hunspell)$/;
    my $set = $web->mcpan->release({ all => [ { distribution => $name }, { status => 'latest' } ] });
    die "latest release for $name returned @{[ $set->total ]} items" if $set->total != 1;
    my $release = $set->next;
    $repos{$name} = $release->download_url;
  }
}

path(__FILE__)->parent->child('.tarballs.txt')->spew(join("\n", sort values %repos));
