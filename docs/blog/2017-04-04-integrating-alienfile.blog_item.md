## Integrating alienfile

By <b>Graham Ollis</b> on 4 April 2017
                        
<a href="http://blogs.perl.org/users/graham_ollis/2017/03/alienfile.html">Last week</a> I 
introduced the M<alienfile> recipe system and we wrote a simple alienfile that provides the 
tool `xz` and the library `liblzma`.  I also showed how to test it using M<App::af>. Today we 
are going to take that alienfile and integrate it into a fully functional M<Alien> 
distribution.

The main motiviation for M<alienfile> + M<Alien::Build> was to separate the alien detection 
and installer code from the perl installer code.  (In fact your alienfile is fully usable 
without any Perl installer at all; you can use your alienfile from a Perl script or Perl 
module using Alien::Build directly).

For our Alien, we will be creating `Alien-xz`, and we will use M<Alien::Build::MM> to provide 
the thin layer of functionality needed between M<ExtUtils::MakeMaker> (EUMM) and 
M<Alien::Build>.  This is what our `Makefile.PL` should look like:

<pre class="sh_perl">
use strict;
use warnings;
use ExtUtils::MakeMaker;
use Alien::Build::MM;

my %WriteMakefileArgs = (
  "ABSTRACT" =&gt; "Find or build xz",
  "AUTHOR" =&gt; "Graham Ollis &lt;plicease\@cpan.org&gt;",
  "VERSION_FROM" =&gt; "lib/Alien/xz.pm",
  "CONFIGURE_REQUIRES" =&gt; {
    "ExtUtils::MakeMaker" =&gt; "6.52",
  },
  "PREREQ_PM" =&gt; {
    "Alien::Base" =&gt; "0.038",
  },
  "DISTNAME" =&gt; "Alien-xz",
  "LICENSE" =&gt; "perl",
  "NAME" =&gt; "Alien::xz",
  "PREREQ_PM" =&gt; {
    "Alien::Base" =&gt; "0.038"
  },
);

my $abmm = Alien::Build::MM-&gt;new;
%WriteMakefileArgs = $abmm-&gt;mm_args(%WriteMakefileArgs);

WriteMakefile(%WriteMakefileArgs);

sub MY::postamble {
  $abmm-&gt;mm_postamble;
}
</pre><!-- summary -->

Most of this will be pretty recognizable to anyone who has hand crafted a `Makefile.PL` 
before.  After constructing the basic arguments that will be passed to `WriteMakefile`, we 
create an instance of M<Alien::Build::MM> and pass the arguments into the `mm_args` method, 
which returns a modified version of those arguments.  This method will decide if it can find 
`xz` and `liblzma` from what is provided by the operating system, or if it should build the 
tool and library from source.  To make this decision it consults the alienfile.  There are 
dynamic prerequisite that depend on the outcome of this decision.  Typcially a build from 
source may pull in additional prerequisite to download or unpack an archive in an unusual 
format, or perhaps the build system requires an extra module or two.  A system install may 
also require additional modules, although that is less common.  At the bottom of the 
`Makefile.PL` we add a postamble to the `Makefile`.  This will add the make targets needed to 
build `xz`.

Note that we declare M<Alien::Base> as a prerequisite because our Alien class will be a subclass 
of that.  We also declare EUMM as a configure time prerequisite which is a good practice for any 
EUMM dist.  We do NOT need to declare M<Alien::Build::MM> as a configure time prerequisite even 
though it is used in the `Makefile.PL` because that is one of the prerequisite that are
addedin by `mm_arg`.

As mentioned earlier, alienfile is not tied to any one Perl installer, so if you prefer you 
can use M<Module::Build> via M<Alien::Build::MB>.  I personally do not recommend this.  It 
just adds extra prerequisite to your Alien.  The sole reason I wrote M<Alien::Build::MB> was to 
act as a proof of concept that: yes M<alienfile> + M<Alien::Build> can be used with any installer 
that meets its requirements.  Including hopefully future installers that are more capable 
than EUMM.  (M<Module::Build::Tiny> will likely never be supported, as it is useful for a 
different subset of things).

If (like me) you do not like mucking about in `Makefile.PL` or `Build.PL` files you can 
instead use the M<Dist::Zilla> plugin M<Dist::Zilla::Plugin::AlienBuild>.

<pre class="ini">
[MakeMaker]
[AlienBuild]
; a little shorter than the Makefile.PL above eh?
</pre>

The next thing that we need is the actual Perl module!  We will call that `lib/Alien/xz.pm`, 
and will look like this:

<pre class="sh_perl">
package Alien::xz;

use strict;
use warnings;
use base qw( Alien::Base );

our $VERSION = '1.00';

1;
</pre>

Not a lot is there?  For most Aliens you will find that the base class does everything that 
you need.  The only thing missing here really, (and I do not reproduce it here for the sake 
of brevity) is documentation.  You should provide your users with enough information in the 
form of POD to be able to use this module!  (See M<Alien::Build::Manual::AlienUser> for clues 
as to what should be included).  If you are lazy like me, you will want to use the 
M<Dist::Zilla> plugin M<Dist::Zilla::Plugin::AlienBase::Doc> to generate synopsis and 
description.

You should of course also provide other common distribution files, such as a `MANIFEST` and a 
`Changes` file, but all of that is beyond the scope of this document.  (Always wanted to say 
that).

Now we can install our Alien like any other distribution.  Create the make file:

<pre class="console">
% perl Makefile.PL
</pre>

You can download the xz tarball using the `alien_download` target:

<pre class="console">
% make alien_download
"/Users/ollisg/opt/perl/5.24.0/bin/perl" -MAlien::Build::MM=cmd -e prefix site /Users/ollisg/opt/perl/5.24.0/my/dev/lib/perl5/darwin-2level /Users/ollisg/opt/perl/5.24.0/my/dev/lib/perl5/darwin-2level /Users/ollisg/opt/perl/5.24.0/my/dev/lib/perl5/darwin-2level
main&gt; prefix /Users/ollisg/opt/perl/5.24.0/my/dev/lib/perl5/darwin-2level/auto/share/dist/Alien-xz
"/Users/ollisg/opt/perl/5.24.0/bin/perl" -MAlien::Build::MM=cmd -e download
Alien::Build::Plugin::Core::Download&gt; decoding html
Alien::Build::Plugin::Core::Download&gt; candidate *http://tukaani.org/xz/xz-5.2.3.tar.gz
Alien::Build::Plugin::Core::Download&gt; setting version based on archive to 5.2.3
Alien::Build::Plugin::Core::Download&gt; downloaded xz-5.2.3.tar.gz
</pre>

(hint, if you are testing this and the system `xz` and `liblzma` are being detected, the 
download step will be a noisy NOOP.  You can set `ALIEN_INSTALL_TYPE` to `share` to override 
this and force a source code build.)

You can then build `xz` and `liblzma` using the `alien_build` target:

<pre class="console">
% make alien_build
"/Users/ollisg/opt/perl/5.24.0/bin/perl" -MAlien::Build::MM=cmd -e build
Alien::Build::CommandSequence&gt; + ./configure --prefix=/Users/ollisg/opt/perl/5.24.0/my/dev/lib/perl5/darwin-2level/auto/share/dist/Alien-xz --with-pic --disable-shared

XZ Utils 5.2.3

System type:
checking build system type... x86_64-apple-darwin15.6.0
checking host system type... x86_64-apple-darwin15.6.0
...
</pre>

(copious output not included).

You can also just do a regular `make all` and it will build the `alien_download` and 
`alien_build` targets, along with the necessary Perl specific targets.

Now we are ready to run the tests:

<pre class="console">
% make test
PERL_DL_NONLAZY=1 "/Users/ollisg/opt/perl/5.24.0/bin/perl" "-MExtUtils::Command::MM" "-MTest::Harness" "-e" "undef *Test::Harness::Switches; test_harness(0, 'blib/lib', 'blib/arch')" t/*.t
t/run.t ...... ok   
t/xs.t ....... ok   
All tests successful.
Files=2, Tests=7,  1 wallclock secs ( 0.03 usr  0.01 sys +  0.70 cusr  0.56 csys =  1.30 CPU)
Result: PASS
</pre>

I waited until now to remind you that you need tests!  It is important to know that the Alien 
will work with your XS module.  You don't want to find out it doesn't work when you are 
installing that.  The best way to do this is to use M<Test::Alien>, which tests your Alien 
with that same tools that your Alien will actually be used with.  Here is a very basic 
M<Test::Alien> test that ensures the alienized `liblzma` works correctly with XS:

<pre class="sh_perl">
use Test2::Bundle::Extended;
use Test::Alien;
use Alien::xz;

alien_ok 'Alien::xz';

xs_ok do { local $/; &lt;DATA&gt; }, with_subtest {
  my $version = lzma::lzma_version_string();
  ok $version;
  note "version = $version";
};

done_testing;

__DATA__

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include &lt;lzma.h&gt;

MODULE = lzma PACKAGE = lzma

const char *
lzma_version_string()
</pre>

...and here is the tool test that ensures the alienized command line `xz` works correctly:

<pre class="sh_perl">
use Test2::Bundle::Extended;
use Test::Alien;
use Alien::xz;

alien_ok 'Alien::xz';

run_ok(['xz', '--version'])
  -&gt;success
  -&gt;out_like(qr{XZ Utils})
  -&gt;note;

done_testing;
</pre>

You are all done writing your Alien.  Although it may seem like you went through a lot, this 
is a lot less work than if you tried to roll your own Alien.  Now we can finally install our 
Alien, and just eyeball test that it works from the command line.

<pre class="console">
% make install
...
% perl -MAlien::xz -E 'say Alien::xz-&gt;version'
5.2.3
% perl -MAlien::xz -E 'say Alien::xz-&gt;cflags'
-I/Users/ollisg/opt/perl/5.24.0/my/dev/lib/perl5/darwin-2level/auto/share/dist/Alien-xz/include 
% perl -MAlien::xz -E 'say Alien::xz-&gt;libs'
-L/Users/ollisg/opt/perl/5.24.0/my/dev/lib/perl5/darwin-2level/auto/share/dist/Alien-xz/lib -llzma 
</pre>

Next time we will use the Alien that we have crafted here from an XS or FFI module, which is 
ultimately the reason for all of this prep work.

<b>Correction</b>: a previous version of this blogity blog incorrectly referred to 
M<Alien::Build::MM> as a dynamic prerequisite.  It is always added so it is strictly speaking a 
static prerequisite.

---

This article was originally posted to [blogs.perl.org](https://blogs.perl.org):
[here](http://blogs.perl.org/users/graham_ollis/2017/04/integrating-alienfile.html)
