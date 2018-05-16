## alienfile

By <b>Graham Ollis</b> on 28 March 2017

M<Alien::Base> was first released in alpha form five years ago this month!  The good things 
that M<Alien::Base> (runtime) and M<Alien::Base::ModuleBuild> (its installer ABMB) did when 
it was unleashed on the world are many, but chiefly:

  1. It suggested a standard way of providing the compiler and linker 
  flags needed to use an already installed alien.  The
  <a href="https://metacpan.org/pod/Alien">original manifesto</a>
  was pretty flip in terms of standards or best practices.

  2. It made it dead simple to create an Alien distribution that
  “alienized” a package that used 
  <a href="https://www.gnu.org/software/autoconf/autoconf.html">autoconf</a> and
  <a href="http://en.wikipedia.org/wiki/pkg-config">pkg-config</a>, which probably covers a majority of open source libraries
  that you would be likely to want to “alienize”.
  (For those who are unfamiliar, autoconf provides a similar
  functionality to M<ExtUtils::MakeMaker> in the C world
  and pkg-config is used to deal with dependencies in the C
  world).
  
  3. It made it possible with some work to create an Alien distribution 
  that wrapped around a package that used vanilla `Makefile`'s, 
  <a href="http://en.wikipedia.org/wiki/CMake">CMake</a>, and in some cases crazy custom installers.

So when I was working on:

  1. M<alienfile>, a new recipe system for M<Alien>
  
  2. M<Alien::Build>, the implementation for that recipe system

intended as a modern pluggable alternative to ABMB, I wanted to make sure this new tech did 
these things at least as well.
(<a href="https://github.com/Perl5-Alien/Alien-Base/issues/157">In a github issue</a> I 
mentioned the motivations for such a move, but briefly, ABMB is tightly coupled with 
M<Module::Build> which has fallen out of favor and is no longer distributed as part of the 
Perl Core). In this dispatch I will cover how alienfile + Alien::Build make these things 
easy.  In dispatches further down the line I will demonstrate what you can do with alienfile 
which is either hard or impossible with ABMB.

Most software package provide instructions on how to install them
as a list of commands that you type into your shell.  For example,
the `xz` package which provides the command line program `xz`
and the library `liblzma<` can be installed using the standard
procedure for autoconf based packages:

<pre class="console">
% ./configure
% make
% make install
</pre>

So intuitively the simplest way to start with alienfile is to put
those commands into an alienfile like this:

<pre class="sh_perl">
use alienfile;

# This example is borrowed from the examples directory of the
# Alien-Build distribution.

# Use pkg-config to check if the library exists.
# also, use which to check that the xz command is
# in the path.
probe [ 
  'pkg-config --exists liblzma',
  'which xz',
];

# If the probe fails to find an already installed xz, the 
# "share" block contains instructions for downloading and
# installing it.
share {

  # the first download which succeeds will be used
  download [ 'wget http://tukaani.org/xz/xz-5.2.3.tar.gz' ];
  download [ 'curl -O http://tukaani.org/xz/xz-5.2.3.tar.gz' ];

  # use tar to extract the tarball
  extract [ 'tar zxf %{.install.download}' ];
  
  # use the standard build process
  build [
    './configure --prefix=%{.install.prefix} --disable-shared',
    '%{make}',
    '%{make} install',
  ];

};

# gather the details necessary for using the library, and store them
# as runtime properties.
gather [
  # store the (chomped) output into the appropriate runtime properties
  [ 'pkg-config', '--modversion', 'liblzma', \'%{.runtime.version}' ],
  [ 'pkg-config', '--cflags',     'liblzma', \'%{.runtime.cflags}'  ],
  [ 'pkg-config', '--libs',       'liblzma', \'%{.runtime.libs}'    ],
];
</pre>

If you have M<App::af> installed, you can test this alienfile with the `af download` command:

<pre class="console">
% af download -f alienfile
Alien::Build::CommandSequence> + wget http://tukaani.org/xz/xz-5.2.3.tar.gz
--2017-03-25 12:48:14--  http://tukaani.org/xz/xz-5.2.3.tar.gz
Resolving tukaani.org... 84.34.147.45
Connecting to tukaani.org|84.34.147.45|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 1490665 (1.4M) [application/x-gzip]
Saving to: 'xz-5.2.3.tar.gz'

xz-5.2.3.tar.gz                 100%[=========================================================>]   1.42M   482KB/s   in 3.0s   

2017-03-25 12:48:17 (482 KB/s) - 'xz-5.2.3.tar.gz' saved [1490665/1490665]

Alien::Build> single file, assuming archive
Wrote archive to /Users/ollisg/dev/Alien-Build/example/xz-5.2.3.tar.gz
</pre>

...and the `af install` command:

<pre class="console">
% af install -f alienfile --prefix=/tmp/foo
... lots of output...
copied staged install into /tmp/foo
---
cflags: -I/tmp/foo/include
cflags_static: -I/tmp/foo/include
install_type: share
legacy:
  finished_installing: 1
  install_type: share
  original_prefix: /tmp/foo
  version: 5.2.3
libs: -L/tmp/foo/lib -llzma
libs_static: -L/tmp/foo/lib -llzma
prefix: /tmp/foo
version: 5.2.3        
</pre>

As you can see an alienfile is a series of steps which can be specified as a list of commands.  Commands can use a 
simple macro or helper facility for portability.  For example, instead of using `make` directly, it is advisable to 
use `%{make}`, since it will be replaced by `dmake` or `nmake` on platforms that use those names instead.  
Some packages require GNU Make, in which case you can use `%{gmake}` and be sure you get the right type of 
`make` (it is a good idea to request the upstream developer to add support for other versions of `make` for better 
portability too).
If a command fails then it will stop the install.  Steps can also be 
specified as a code reference when they can more easily be expressed as 
Perl code.  If the code reference throws an exception it will stop the 
install.  These are the basic steps that an alienfile will need to 
define in most cases:

 * <b>probe</b> - see if the library or tool is already installed on the system.
 * <b>share</b> - block containing steps for when the library or tool needs to be built from source.
    * <b>download</b> - download, usually a tarball or zip file from the internet.
    * <b>extract</b> - extract the files from that tarball or zip file.</li>
    * <b>build</b> - build the source.

There is also a <b>sys</b> block for steps that happen only during an install when the 
library or tool is already installed on the system, and a <b>gather</b> step, which gathers 
the details on how to use the library or tool that will be needed by the Alien runtime when 
the Alien is installed.  The <b>gather</b> step can be placed in either or both of the 
<b>share</b> or <b>sys</b> block, allowing different gather mechanisms to be used depending 
on the install type.  You can also put the <b>gather</b> (as in the example above) step 
outside of either bock, which is the same as putting the identical instructions in both 
blocks.

This manual example is great for seeing how alienfile works, but typically for autoconf and pkg-config based 
projects you will want to use plugins:

<pre class="sh_perl">
use alienfile;

plugin 'PkgConfig' => 'liblzma';

plugin 'Probe::CommandLine' => (
  command   => 'xz',
  secondary => 1,
);

share {

  plugin Download => (
    url     => 'http://tukaani.org/xz/',
    version => qr/^xz-([0-9\.]+)\.tar\.gz$/,
  );

  plugin Extract => 'tar.gz';

  plugin 'Build::Autoconf' => ();

  # the build step is only necessary if you need to customize the
  # options passed to ./configure.  The default set by the
  # Build::Autoconf plugin is frequently sufficient.
  build [
    '%{configure} --disable-shared',
    '%{make}',
    '%{make} install',
  ];
};
</pre>

This does more or less the same thing as the previous example with
a much more concise recipe.  It does a number of things better than
the first example though:

  * The [PkgConfig](https://metacpan.org/pod/Alien::Build::Plugin::PkgConfig::Negotiate)
    plugin will pick the best method for querying the
    pkg-config database.  This might be using the pkg-config command, or it
    might mean using the pure-perl alternative PkgConfig.pm
    on platforms that don't provide their own pkg-config.
  * The [Download](https://metacpan.org/pod/Alien::Build::Plugin::Download::Negotiate)
    plugin will download the latest version of xz, not the 
    specific version requested in the first alienfile.  It also will work
    even if `wget` or `curl` aren't available, unlike the previous
    version.
  * The [Build::Autoconf](https://metacpan.org/pod/Alien::Build::Plugin::Build::Autoconf)
    plugin is much more reliable for most autoconf packages (because it does a double staged 
    install, ask me if you really want to know the details).  It is also smart enough to work 
    on windows, which is a tricky thing to do manually!

So that is a lot already.  I can tell as your eyes are starting to glaze over!  And you have 
already learned a lot.  Next time I will show you how to integrate your alienfile recipe into 
an Alien distribution and how to use it from your XS module.

---

This article was originally posted to [blogs.perl.org](https://blogs.perl.org):
[here](http://blogs.perl.org/users/graham_ollis/2017/03/alienfile.html)
