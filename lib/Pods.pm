use strict;
use warnings;
use 5.020;
use experimental qw( signatures postderef );

package Pods {

  use Archive::Libarchive::Peek;
  use LWP::UserAgent;
  use URI;
  use URI::file;
  use Path::Tiny ();
  use Template;

  sub new ($class) {
    bless {}, $class;
  }

  sub ua ($self, $new=undef) {
    if($new) {
      $self->{ua} = $new;
    }
    my $ua = $self->{ua} ||= LWP::UserAgent->new;
    $ua->env_proxy;
    $ua;
  }

  sub add_dist ($self, $location) {
    my $url = -f $location ? URI::file->new(Path::Tiny->new($location)->absolute->stringify) : URI->new($location);
    say "$url";
    my $res = $self->ua->get($url);
    if($res->is_success) {
      my $tarball = $res->decoded_content;
      my $peek = Archive::Libarchive::Peek->new(
        memory => \$tarball,
      );
      $peek->iterate(sub ($filename, $content, $e) {
        return unless $e->filetype eq 'reg';

        # want to also handle bin directory
        if($filename =~ m{^[^/]+/lib/(.+)$})
        {
          my $path = $1;
          if($path =~ /\.(pod|pm)$/)
          {
            my $name = $path;
            $name =~ s{\.(pod|pm)$}{};
            $name =~ s{/}{::}g;

            my $href = $path;
            $href =~ s{\.(pod|pm)$}{.html};

            $self->{pod}->{$name} = {
              content => $content,
              href    => $self->url_prefix . $href,
            };
          }
          else
          {
            say "data: $path";
            $self->{data}->{$path} = $content;
          }
        }
        elsif($filename =~ m{^[^/]+/bin/(.+)$})
        {
          my $name = $1;
          $self->{pod}->{$name} = {
            content => $content,
            href    => $self->url_prefix . "$name.html",
          };
        }
      });
    } else {
      die "error fetching $url: @{[ $res->status_line ]}";
    }
  }

  sub current ($self, $new=undef) {
    if(defined $new) {
      $self->{current} = $new;
    }
    $self->{current};
  }

  sub tt ($self, $new=undef) {
    $self->{tt} = $new if defined $new;
    $self->{tt} ||= Template->new(
      WRAPPER            => 'wrapper.html.tt',
      INCLUDE_PATH       => Path::Tiny->new(__FILE__)->parent->parent->child('templates')->stringify,
      render_die         => 1,
      TEMPLATE_EXTENSION => '.tt',
      ENCODING           => 'utf8',
    );
  }

  sub fs_root ($self, $new=undef) {
    $self->{fs_root} = $new if defined $new;
    $self->{fs_root} ||= Path::Tiny->new(__FILE__)->parent->parent->child('docs', 'pod');
  }

  sub url_prefix ($self, $new=undef) {
    $self->{url_prefix} = $new if defined $new;
    $self->{url_prefix} ||= "/pod/"
  }

  sub generate_html ($self) {

    foreach my $name (sort keys $self->{pod}->%*)
    {
      my $p = Pods::HTML->new;
      my $html;
      $p->output_string(\$html);
      $p->index(1);
      $p->html_header_before_title('<!--');
      $p->html_header_after_title('-->');
      $p->html_footer('');
      $p->pods($self);
      $p->{Tagmap}->{'Verbatim'} = "\n<pre class=\"sh_perl\">";
      $p->{Tagmap}->{'VerbatimFormatted'} = "\n<pre class=\"sh_perl\">";
      $self->current($name);

      $p->parse_string_document($self->{pod}->{$name}->{content});

      my $path = $self->fs_root->child(do {
        my @parts = split /::/, $name;
        $parts[-1] .= '.html';
        @parts;
      });

      $path->parent->mkpath;

      my $full_html;
      $self->tt->process('pod.html.tt', {
        title => $name,
        h1    => $name,
        pod   => $html,
        shjs  => "https://shjs.wdlabs.com"
      }, \$full_html);
      
      $path->spew_utf8($full_html);
    }

    foreach my $path (sort keys $self->{data}->%*) {
      my $content = $self->{data}->{$path};
      $path = $self->fs_root->child($path);
      $path->parent->mkpath;
      $path->spew_raw($content);
    }
  }

  sub get_link ($self, $name) {
    $self->{pod}->{$name}->{href};
  }

}

package Pods::HTML {

  use parent qw( Pod::Simple::HTML );

  sub pods ($self, $new=undef) {
    if($new) {
      $self->{pods} = $new;
    }
    $self->{pods};
  }

  sub do_pod_link ($self, $link) 
  {
    if($link->tagname eq 'L' && $link->attr('type') eq 'pod') {
      my $to      = $link->attr('to');
      my $section = $link->attr('section');
      if(defined $to)
      {
        if(my $path = $self->pods->get_link($to)) {
          $path .= "#" . $self->section_escape($section) if defined $section;
          return $path;
        }
      }
      else
      {
        if(defined $section) {
          return "#" . $self->section_escape($section);
        }
      }
    }
    return $self->SUPER::do_pod_link($link);
  }

}

1;
