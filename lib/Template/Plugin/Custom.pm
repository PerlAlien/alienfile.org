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
      my(undef, $link) = @_;

      sub {
        my $text = shift;

        # strip off anything under a hr
        ($text) = split /\n---\n/, $text;

        my $more = "[... read more]($link)";

        if($text =~ /\<\!-- summary --\>/)
        {
          # document contains summary mark
          ($text) = split /\<\!-- summary --\>/, $text;
          $text =~ s/^(#+) (.*)\n(.*)/$1 [$2]($link)\n$3/;
          $text .= "\n\n$more\n";
        }
        else
        {
          # include the first 5 "paragraphs" for the summary
          my @para = split /\n\n/, $text;
          $para[0] =~ s/^(#+) (.*)$/$1 [$2]($link)/;
          $text = join("\n\n", @para[0..4]) . "\n\n$more\n";
        }
      
        $text;
      }
    }, 1,
  );
  
  return $self;
}

1;
