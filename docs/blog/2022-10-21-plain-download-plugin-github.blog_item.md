## Plain Download Plugin + GitHub

By *Graham Ollis* on 21 October 2022

Recently, GitHub changed their release pages such that the download
links are no longer parseable without JavaScript.  This unfortunately
breaks the use of the plain M<Download negotiation plugin|Alien::Build::Plugin::Download::Negotiate>
which picks the best plugins to download and parse the HTML to get the
download links.  The symptom is that your M<Alien> which was previously
working dies on a diagnostic like this:

```
no matching files in listing at /opt/perl-5.36.0/lib/site_perl/5.36.0/Alien/Build/Plugin/Core/Download.pm line 43.
```

Fortunately there is an alternative!  The M<Download::GitHub|Alien::Build::Plugin::Download::GitHub>
plugin uses the GitHub API to get the releases.  The TL;DR is that if you have
something like this:

```perl
share {
  start_url 'https://github.com/org/repo/releases';
  plugin 'Download' => (
    filter  => qr/^v.*\.tar\.gz$/,
    version => qr/([0-9\.]+)/,
  );
  plugin Extract => 'tar.gz';
  ...
}
```

You instead want to do something like this:

```perl
share {
  plugin 'Download::GitHub' => (
    github_user => 'org',
    github_repo => 'repo',
  );
  ...
}
```

Note that you no longer need to specify a `start_url` or the
M<Extract negotiation plugin|Alien::Build::Plugin::Extract::Negotiate>,
because the M<Download::GitHub plugin|Alien::Build::Plugin::Download::GitHub>
does that for you.

The M<Download::GitHub plugin|Alien::Build::Plugin::Download::GitHub>
has a number of advanced options, like fetching assets from the release
or tarballs from arbitrary tags, so please review the documentation.
Depending on how the alienized package is organized upstream you may
have to adapt!
