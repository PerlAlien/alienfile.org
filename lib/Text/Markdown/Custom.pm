package Text::Markdown::Custom;

use strict;
use warnings;
use base 'Text::Markdown::PerlExtensions', 'Exporter';

our @EXPORT_OK = qw( markdown );

sub _DoCodeSpans
{
  my ($self, $text) = @_;

    $text =~ s@
            (?<!\\)        # Character before opening ` can't be a backslash
            (`+)        # $1 = Opening run of `
            ([a-z_0-9]+)\n
            (.+?)        # $2 = The code block
            (?<!`)
            \1            # Matching closer
            (?!`)
        @
             my $lang = "$2";
             my $c = "$3";
             $c =~ s/^[ \t]*//g; # leading whitespace
             $c =~ s/[ \t]*$//g; # trailing whitespace
             $c = $self->_EncodeCode($c);
            "<pre class=\"sh_$lang\">$c</pre>";
        @egsx;  

  $text = $self->SUPER::_DoCodeSpans($text);
  
  $text;
}

sub markdown
{
  my($text) = @_;
  
  my $self = __PACKAGE__->new;
  
  $self->SUPER::markdown($text);
}

1;
