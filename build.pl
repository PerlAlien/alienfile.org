#!/usr/bin/env perl

use strict;
use warnings;
use FindBin ();
use lib "$FindBin::Bin/lib";
use 5.026;
use experimental qw( signatures postderef );
use Template;
use Path::Tiny qw( path );
use Text::Markdown::Custom;
use Pods;
use Path::Tiny qw( path );

my $root = path(__FILE__)->parent;

my $tt = Template->new(
  WRAPPER            => 'wrapper.html.tt',
  INCLUDE_PATH       => $root->child('templates')->stringify,
  render_die         => 1,
  TEMPLATE_EXTENSION => '.tt',
  ENCODING           => 'utf8',
);

my $pods = Pods->new;
foreach my $url (path('.tarballs.txt')->lines( { chomp => 1 } ))
{
  $pods->add_dist($url);
}
$pods->fs_root->remove_tree;
$pods->generate_html;

Text::Markdown::Custom->pods($pods);

$root->child('docs')->visit(
  sub ($md_path, $) {
    return unless $md_path->basename =~ /\.md$/;

    my($html_path, undef, $template_name) = $md_path->basename =~ /^(.*?)(\.(.*))?\.md$/;
    
    $template_name ||= 'simple';
    $html_path = $md_path->sibling($html_path . '.html');
    
    my $out = '';
    
    my @lines = $md_path->lines_utf8;
    my $title = 'alienfile.org';
    my $h1;

    if($lines[0] =~ m/^##+\s*(\S.*)$/)
    {
      $title = $1;
    }
    elsif($lines[0] =~ m/^#\s*(\S.*)$/)
    {
      $h1 = $title = $1;
      shift @lines;
    }

    my $template_path = $root->child("templates/$template_name.html.tt");
    say "$md_path ($template_path)";
    die "no such tempalte $template_path" unless -f $template_path;

    my $html = $tt->process(
      $template_path->basename,
      {
        title     => $title,
        h1        => $h1,
        markdown  => Text::Markdown::Custom->new->markdown(join('', @lines)),
        directory => $md_path->parent,
        shjs      => "https://shjs.wdlabs.com",
      },
      \$out,
    ) || die $tt->error;
    
    say "  -> $html_path";
    
    $html_path->spew_utf8($out);

  },
  { recurse => 1 },
);
