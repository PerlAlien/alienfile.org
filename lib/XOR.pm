package XOR {

  use strict;
  use warnings;
  use 5.024;
  use experimental qw( signatures );
  use XOR::Pods;
  use XOR::Web;
  use XOR::Markdown;
  use XOR::TarballList;
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

  sub tt ($self)
  {
    $self->{tt} ||= Template->new(
      WRAPPER            => 'wrapper.html.tt',
      INCLUDE_PATH       => Path::Tiny->new('.')->absolute->child('templates')->stringify,
      render_die         => 1,
      TEMPLATE_EXTENSION => '.tt',
      ENCODING           => 'utf8',
    );
  }

  sub tarball_list ($self)
  {
    $self->{tarball_list} ||= XOR::TarballList->new;
  }

}

1;
