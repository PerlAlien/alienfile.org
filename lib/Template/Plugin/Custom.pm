package Template::Plugin::Custom;

use strict;
use warnings;
use Text::Markdown::Custom;
use base qw (Template::Plugin::Filter);

sub new
{
  my($class, $context, @args) = @_;
  
  my $self = bless {
    _CONTEXT => $context,
  }, $class;
  
  $context->define_filter(
    markdown => sub {
      my($text) = @_;
      Text::Markdown::Custom::markdown($text);
    },
  );
  
  $context->define_filter(
    summary => sub {
      my($text) = @_;
      
      # strip off anything under a hr
      ($text) = split /\n---\n/, $text;

      # split into paragraphs, roughly speaking
      my @para = split /\n\n/, $text;
      
      # include the first 5 "paragraphs" for the summary
      @para > 5
        ? join("\n\n", @para[0..4]) . "\n\n...\n"
        : $text;
    },
  );
  
  return $self;
}

1;
