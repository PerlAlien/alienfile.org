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

      if($text =~ /\<\!-- summary --\>/)
      {
        ($text) = split /\<\!-- summary --\>/, $text;
        $text .= "\n\n...\n";
      }
      else
      {
        my @para = split /\n\n/, $text;
        $text = join("\n\n", @para[0..4]) . "\n\n...\n";
      }
      
      # include the first 5 "paragraphs" for the summary
      $text;
    },
  );
  
  return $self;
}

1;
