package XOR {

  use strict;
  use warnings;
  use 5.024;
  use experimental qw( signatures );
  use XOR::Pods;
  use XOR::Web;
  use XOR::Markdown;
  use YAML ();

  sub new ($class)
  {
    state $singleton;
    $singleton ||= bless {}, __PACKAGE__;
  }

  sub pods ($self)
  {
    $self->{pods} ||= XOR::Pods->new;
  }

  sub web ($self)
  {
    $self->{web} ||= XOR::Web->new;
  }

  sub markdown ($self)
  {
    $self->{markdown} ||= XOR::Markdown->new;
  }

}

1;
