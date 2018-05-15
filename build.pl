#!/usr/bin/env perl

use strict;
use warnings;
use 5.026;
use Template;
use Path::Tiny qw( path );
use Text::Markdown qw( markdown );

my $root = path(__FILE__)->parent;

my $tt = Template->new(
  WRAPPER            => 'wrapper.html.tt',
  INCLUDE_PATH       => $root->child('templates')->stringify,
  render_die         => 1,
  TEMPLATE_EXTENSION => '.tt',
);

$root->child('docs')->visit(
  sub {
    my($md_path) = @_;
    return unless $md_path->basename =~ /\.md$/;

    my($html_path, undef, $template_name) = $md_path->basename =~ /^(.*?)(\.(.*))?\.md$/;
    
    $template_name ||= 'simple';
    $html_path = $md_path->sibling($html_path . '.html');
    
    my $out = '';
    
    my @lines = $md_path->lines_utf8;
    
    my($title) = $lines[0] =~ /^#+\s(.*)$/;
    $title ||= 'alienfile.org';

    my $template_path = $root->child("templates/$template_name.html.tt");
    say "$md_path ($template_path)";
    die "no such tempalte $template_path" unless -f $template_path;

    my $html = $tt->process(
      $template_path->basename,
      {
        title     => $title,
        markdown  => markdown(join '', @lines),
        directory => $md_path->parent,
      },
      \$out,
    ) || die $tt->error;
    
    say "  -> $html_path";
    
    $html_path->spew_utf8($out);

  },
  { recurse => 1 },
);
