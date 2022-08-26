package Web;

use strict;
use warnings;
use 5.020;
use experimental qw( signatures );
use Path::Tiny qw( path );
use CHI;
use WWW::Mechanize::Cached;
use HTTP::Tiny::Mech;
use URI;
use MetaCPAN::Client;

sub ua ($class)
{
  HTTP::Tiny::Mech->new(
    mechua => WWW::Mechanize::Cached->new(
      cache => CHI->new(
        driver   => 'File',
        root_dir => path(__FILE__)->parent->parent->child('./.web-cache')->stringify,
      ),
    )
  );
}

sub mcpan ($class)
{
  MetaCPAN::Client->new(ua => $class->ua);
}

sub get ($class, $url)
{
  $url = URI->new($url) unless ref $url;

  if($url->scheme eq 'file')
  {
    return path($url->file)->slurp_raw;
  }

  my $res = $class->ua->get($url);
  return $res->{content} if $res->{success};
  die "error fetching $url: @{[ $res->{status} ]} @{[ $res->{reason} ]}";
}

1;



