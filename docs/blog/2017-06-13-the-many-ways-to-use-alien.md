## The many ways to use Alien

By <b>Graham Ollis</b> on 13 June 2017

[A while back](http://blogs.perl.org/users/graham_ollis/2017/03/alienfile.html) I introduced 
the M<alienfile> recipe system and we wrote a simple alienfile that provides in a CPAN context 
the tool `xz` and the library `liblzma`.  I also went over how to test it with M<App::af>.
[The week after that](http://blogs.perl.org/users/graham_ollis/2017/04/integrating-alienfile.html)
I showed how to integrate that alienfile into a fully functioning M<Alien> called M<Alien::xz> 
and promised to show how to then use that Alien from an XS or FFI module.  Today I am going to 
do that. I am also going to show how to use a tool oriented Alien module.  (conveniently, 
Alien::xz can be used in either library or tool oriented Alien mode). If you are more 
interested in FFI or tool oriented mode feel free to skip down to the appropriate 
paragraph.

First, lets suppose we have a very simple XS and Perl module that gives us the version of 
liblzma. This admittedly doesn't do anything very useful without the rest of the library, but 
it will help us test the basics of how to call a library that has been alienized.  (if you 
need real LZMA support you should probably use M<IO::Compress::Lzma> of course).<!-- summary -->

<center><pre style="margin: 10px 10px 0 10px; padding: 10px; background-color: blue; color: white; ">
lib/LZMA/Example.pm (XS)
</pre></center>

<pre style="border: 1px solid lightgray; margin: 0 10px 10px 10px; padding: 10px; " class="sh_perl">
package LZMA::Example;

use strict;
use warnings;
use base qw( Exporter );

our $VERSION = '0.01';
our \@EXPORT = qw( lzma_version_string );

require XSLoader;
XSLoader::load('LZMA::Example', $VERSION);

1;
</pre>

<center><pre style="margin: 10px 10px 0 10px; padding: 10px; background-color: blue; color: white; ">
Example.xs
</pre></center>
<pre style="border: 1px solid lightgray; margin: 0 10px 10px 10px; padding: 10px;">
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "lzma.h"

MODULE = LZMA::Example PACKAGE = LZMA::Example

const char *
lzma_version_string()
</pre>

I will also write a very short test to make sure that everything is working (this test will be 
used for every single version that I am going to show today):

<center><pre style="margin: 10px 10px 0 10px; padding: 10px; background-color: blue; color: white; ">
t/lzma_example.t
</pre></center>

<pre style="border: 1px solid lightgray; margin: 0 10px 10px 10px; padding: 10px; " class="sh_perl">
use Test2::Bundle::Extended;
use LZMA::Example;

my $version = lzma_version_string();

ok $version, 'returns a version';
note "version = $version";

done_testing;
</pre>

Now Perl's philosophy is of course <i>There's more than one way to do it</i>, so we can use a 
variety of methods for building this as a Perl library.  First we will show how to use 
M<ExtUtils::MakeMaker> (EUMM), since it comes bundled with Perl.  The challenge with EUMM is 
that setting the compiler and linker flags <i>in the correct order</i> can be tricky.  Without 
a lot of effort it should work okay when you are using either the <b>system</b> or 
<b>share</b> install for Alien::xz, but if you forced a <b>share</b> install using the 
`ALIEN_INSTALL_TYPE` environment variable, then there is a very good chance that you will get 
the flag order wrong and use the wrong version of the library or to use the <b>system</b> 
library with your <b>share</b> install or vice versa.  If that happens, you are going to have 
a bad day!  To avoid this, I've written M<Alien::Base::Wrapper>, which generates the correct 
flag order for you!  Here is the example:

<center><pre style="margin: 10px 10px 0 10px; padding: 10px; background-color: blue; color: white; ">
Makefile.PL
</pre></center>

<pre style="border: 1px solid lightgray; margin: 0 10px 10px 10px; padding: 10px; " class="sh_perl">
use strict;
use warnings;
use ExtUtils::MakeMaker;
use Alien::Base::Wrapper qw( Alien::xz );

WriteMakefile(
  NAME               =&gt; 'LZMA::Example',
  VERSION_FROM       =&gt; 'lib/LZMA/Example.pm',
  CONFIGURE_REQUIRES =&gt; {
    'ExtUtils::MakeMaker' =&gt; 6.52,
    'Alien::xz'           =&gt; '0.05',
  },
  Alien::Base::Wrapper-&gt;mm_args,
);
</pre>

Although not used here, one of the neat things about Alien::Base::Wrapper is that you can use 
multiple Aliens in one `Makefile.PL`:

<pre style="border: 1px solid lightgray; margin: 10px; padding: 10px; " class="sh_perl">
...
use Alien::Base::Wrapper qw( Alien::Foo Alien::Bar Alien::Baz );
...
</pre>

But back to our LZMA::Example module.  We can now build the module and run using perl and 
`make`.

<pre style="border: 1px solid lightgray; margin: 10px; padding: 10px; white-space: pre-wrap; " class="console">
% <b style="color: white;">perl Makefile.PL</b>
Generating a Unix-style Makefile
Writing Makefile for LZMA::Example
Writing MYMETA.yml and MYMETA.json
% <b style="color: white;">make</b>
Skip blib/lib/LZMA/Example.pm (unchanged)
Running Mkbootstrap for Example ()
chmod 644 "Example.bs"
"/home/ollisg/perl5/perlbrew/perls/perl-5.26.0tc/bin/perl5.26.0" -MExtUtils::Command::MM -e 'cp_nonempty' -- Example.bs blib/arch/auto/LZMA/Example/Example.bs 644
clang -c  -I/home/ollisg/.perlbrew/libs/perl-5.26.0tc@dev/lib/perl5/x86_64-linux-thread-multi/auto/share/dist/Alien-xz/include -D_REENTRANT -D_GNU_SOURCE -fno-strict-aliasing -pipe -fstack-protector-strong -I/usr/local/include -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -D_FORTIFY_SOURCE=2 -O2   -DVERSION=\"0.01\" -DXS_VERSION=\"0.01\" -fPIC "-I/home/ollisg/perl5/perlbrew/perls/perl-5.26.0tc/lib/5.26.0/x86_64-linux-thread-multi/CORE"   Example.c
rm -f blib/arch/auto/LZMA/Example/Example.so
LD_RUN_PATH="/lib/x86_64-linux-gnu" clang  -L/home/ollisg/.perlbrew/libs/perl-5.26.0tc@dev/lib/perl5/x86_64-linux-thread-multi/auto/share/dist/Alien-xz/lib -pthread -shared -O2 -L/usr/local/lib -fstack-protector-strong Example.o  -o blib/arch/auto/LZMA/Example/Example.so  \
   -llzma   \

chmod 755 blib/arch/auto/LZMA/Example/Example.so
% <b style="color: white;">make test TEST_VERBOSE=1</b>
"/home/ollisg/perl5/perlbrew/perls/perl-5.26.0tc/bin/perl5.26.0" -MExtUtils::Command::MM -e 'cp_nonempty' -- Example.bs blib/arch/auto/LZMA/Example/Example.bs 644
PERL_DL_NONLAZY=1 "/home/ollisg/perl5/perlbrew/perls/perl-5.26.0tc/bin/perl5.26.0" "-MExtUtils::Command::MM" "-MTest::Harness" "-e" "undef *Test::Harness::Switches; test_harness(1, 'blib/lib', 'blib/arch')" t/*.t
t/lzma_example.t ..
# Seeded srand with seed '20170611' from local date.
ok 1 - returns a version
# version = 5.2.3
1..1
ok
All tests successful.
Files=1, Tests=1,  0 wallclock secs ( 0.02 usr  0.00 sys +  0.08 cusr  0.00 csys =  0.10 CPU)
Result: PASS
</pre>

We can do the same thing with M<Module::Build> (MB), although that adds extra dependencies:

<center><pre style="margin: 10px 10px 0 10px; padding: 10px; background-color: blue; color: white; ">
Build.PL
</pre></center>

<pre style="border: 1px solid lightgray; margin: 0 10px 10px 10px; padding: 10px; " class="sh_perl">
use strict;
use warnings;
use Module::Build;
use Alien::xz;

my $build = Module::Build-&gt;new(
  module_name =&gt; 'LZMA::Example',
  dist_abstract =&gt; 'lzma example',
  configure_requires =&gt; {
    'Alien::xz' =&gt; '0.05',
  },
  extra_compiler_flags =&gt; Alien::xz-&gt;cflags,
  extra_linker_flags   =&gt; Alien::xz-&gt;libs,
);

$build-&gt;create_build_script;
</pre>

<pre style="border: 1px solid lightgray; margin: 10px; padding: 10px; white-space: pre-wrap; " class="console">
% <b style="color: white;">perl Build.PL</b>
Created MYMETA.yml and MYMETA.json
Creating new 'Build' script for 'LZMA-Example' version '0.01'
% <b style="color: white;">./Build</b>
Building LZMA-Example
clang -I/home/ollisg/perl5/perlbrew/perls/perl-5.26.0tc/lib/5.26.0/x86_64-linux-thread-multi/CORE -DVERSION="0.01" -DXS_VERSION="0.01" -fPIC -I/home/ollisg/.perlbrew/libs/perl-5.26.0tc@dev/lib/perl5/x86_64-linux-thread-multi/auto/share/dist/Alien-xz/include -c -D_REENTRANT -D_GNU_SOURCE -fno-strict-aliasing -pipe -fstack-protector-strong -I/usr/local/include -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -D_FORTIFY_SOURCE=2 -O2 -o lib/LZMA/Example.o lib/LZMA/Example.c
ExtUtils::Mkbootstrap::Mkbootstrap('blib/arch/auto/LZMA/Example/Example.bs')
clang -shared -O2 -L/usr/local/lib -fstack-protector-strong -o blib/arch/auto/LZMA/Example/Example.so lib/LZMA/Example.o -L/home/ollisg/.perlbrew/libs/perl-5.26.0tc@dev/lib/perl5/x86_64-linux-thread-multi/auto/share/dist/Alien-xz/lib -llzma
% <b style="color: white;">./Build test verbose=1</b>
t/lzma_example.t ..
# Seeded srand with seed '20170611' from local date.
ok 1 - returns a version
# version = 5.2.3
1..1
ok
All tests successful.
Files=1, Tests=1,  0 wallclock secs ( 0.01 usr  0.01 sys +  0.08 cusr  0.01 csys =  0.11 CPU)
Result: PASS
</pre>

Some people like M<Dist::Zilla> instead:

<center><pre style="margin: 10px 10px 0 10px; padding: 10px; background-color: blue; color: white; ">
dist.ini
</pre></center>
<pre style="border: 1px solid lightgray; margin: 0 10px 10px 10px; padding: 10px; ">
name     = LZMA-Example
version  = 0.01
abstract = LZMA example

[@Filter]
-bundle = @Basic
-remove = MakeMaker

[Prereqs / ConfigureRequires]
Alien::xz = 0.05

[MakeMaker::Awesome]
header            = use Config;
header            = use Alien::xz;
WriteMakefile_arg = CCFLAGS =&gt; Alien::xz-&gt;cflags . ' ' . $Config{ccflags}
WriteMakefile_arg = LIBS =&gt; [ Alien::xz-&gt;libs ]
</pre>

<pre style="border: 1px solid lightgray; margin: 10px; padding: 10px; white-space: pre-wrap; " class="console">
% <b style="color: white;">dzil test</b>
[DZ] building distribution under .build/4IIoWEI6uU for installation
[DZ] beginning to build LZMA-Example
[DZ] writing LZMA-Example in .build/4IIoWEI6uU
Checking if your kit is complete...
Looks good
Generating a Unix-style Makefile
Writing Makefile for LZMA::Example
Writing MYMETA.yml and MYMETA.json
cp lib/LZMA/Example.pm blib/lib/LZMA/Example.pm
Running Mkbootstrap for Example ()
chmod 644 "Example.bs"
"/home/ollisg/perl5/perlbrew/perls/perl-5.26.0tc/bin/perl5.26.0" -MExtUtils::Command::MM -e 'cp_nonempty' -- Example.bs blib/arch/auto/LZMA/Example/Example.bs 644
"/home/ollisg/perl5/perlbrew/perls/perl-5.26.0tc/bin/perl5.26.0" "/home/ollisg/perl5/perlbrew/perls/perl-5.26.0tc/lib/5.26.0/ExtUtils/xsubpp"  -typemap '/home/ollisg/perl5/perlbrew/perls/perl-5.26.0tc/lib/5.26.0/ExtUtils/typemap'  Example.xs > Example.xsc
Please specify prototyping behavior for Example.xs (see perlxs manual)
mv Example.xsc Example.c
clang -c   -I/home/ollisg/.perlbrew/libs/perl-5.26.0tc@dev/lib/perl5/x86_64-linux-thread-multi/auto/share/dist/Alien-xz/include  -D_REENTRANT -D_GNU_SOURCE -fno-strict-aliasing -pipe -fstack-protector-strong -I/usr/local/include -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -D_FORTIFY_SOURCE=2 -O2   -DVERSION=\"0.01\" -DXS_VERSION=\"0.01\" -fPIC "-I/home/ollisg/perl5/perlbrew/perls/perl-5.26.0tc/lib/5.26.0/x86_64-linux-thread-multi/CORE"   Example.c
rm -f blib/arch/auto/LZMA/Example/Example.so
clang  -shared -O2 -L/usr/local/lib -fstack-protector-strong Example.o  -o blib/arch/auto/LZMA/Example/Example.so  \
   -L/home/ollisg/.perlbrew/libs/perl-5.26.0tc@dev/lib/perl5/x86_64-linux-thread-multi/auto/share/dist/Alien-xz/lib -llzma   \

chmod 755 blib/arch/auto/LZMA/Example/Example.so
"/home/ollisg/perl5/perlbrew/perls/perl-5.26.0tc/bin/perl5.26.0" -MExtUtils::Command::MM -e 'cp_nonempty' -- Example.bs blib/arch/auto/LZMA/Example/Example.bs 644
PERL_DL_NONLAZY=1 "/home/ollisg/perl5/perlbrew/perls/perl-5.26.0tc/bin/perl5.26.0" "-MExtUtils::Command::MM" "-MTest::Harness" "-e" "undef *Test::Harness::Switches; test_harness(0, 'blib/lib', 'blib/arch')" t/*.t
t/lzma_example.t .. ok
All tests successful.
Files=1, Tests=1,  1 wallclock secs ( 0.02 usr  0.01 sys +  0.09 cusr  0.00 csys =  0.12 CPU)
Result: PASS
[DZ] all's well; removing .build/4IIoWEI6uU
</pre>

As many may already know, an alternative way to write “XS” modules is by using M<Inline::C> or 
M<Inline::CPP>.  One of the advantages to this is that the code can be compiled on demand as 
needed.  Also all of your code can be contained within the Perl source file. Happily 
M<Alien::Base> and all library modules that use it work quite nicely with M<Inline>, and in 
order to integrate the two you can use the `with` keyword when writing your Inline 
module:

<center><pre style="margin: 10px 10px 0 10px; padding: 10px; background-color: blue; color: white; ">
lib/LZMA/Example.pm (Inline)
</pre></center>
<pre style="border: 1px solid lightgray; margin: 0 10px 10px 10px; padding: 10px; " class="sh_perl">
package LZMA::Example;

use strict;
use warnings;
use Inline with =&gt; 'Alien::xz';
use Inline C =&gt; &lt;&lt;'END';
#include &lt;lzma.h&gt;
const char * _version_string()
{
  return lzma_version_string();
}
END
use base qw( Exporter );

our $VERSION = '0.01';
our @EXPORT = qw( lzma_version_string );

sub lzma_version_string
{
  _version_string();
}

1;
</pre>

<pre style="border: 1px solid lightgray; margin: 10px; padding: 10px; white-space: pre-wrap; " class="console">
% <b style="color: white;">prove -lvm t</b>
t/lzma_example.t ..
# Seeded srand with seed '20170611' from local date.
ok 1 - returns a version
# version = 5.2.3
1..1
ok
All tests successful.
Files=1, Tests=1,  1 wallclock secs ( 0.03 usr  0.00 sys +  0.25 cusr  0.01 csys =  0.29 CPU)
Result: PASS
</pre>


One of the downsides to using Alien and Inline together like this is that the Alien module 
becomes a run-time dependency for your module.  In the previous XS examples, Alien::xz was 
only a configure time dependency.  This is likely mostly of concern to integrators building 
operating system packages for Perl modules, but it might be something to think about as a 
developer as well.

Another way to call a library from Perl is to use FFI.  There are two usable FFI systems on 
CPAN, M<FFI::Raw> and M<FFI::Platypus>.  (I personally recommend Platypus over Raw).  FFI has 
some advantages and disadvantages over XS: your code is in one Perl file, it does not even 
need to be “built” or “installed” to be used, it introduces <i>some</i> additional complexity, 
since both Platypus and Raw are implemented using XS, it needs any Aliens as run-time 
dependencies (just as with Inline), etc.

Here is an example of our LZMA module using M<FFI::Platypus>:

<center><pre style="margin: 10px 10px 0 10px; padding: 10px; background-color: blue; color: white; ">
lib/LZMA/Example.pm (FFI)
</pre></center>
<pre style="border: 1px solid lightgray; margin: 0 10px 10px 10px; padding: 10px; " class="sh_perl">
package LZMA::Example;

use strict;
use warnings;
use FFI::Platypus;
use Alien::xz;
use base qw( Exporter );

our $VERSION = '0.01';
our @EXPORT = qw( lzma_version_string );

my $ffi = FFI::Platypus-&gt;new(
  lib =&gt; [ Alien::xz-&gt;dynamic_libs ],
);

$ffi-&gt;attach( lzma_version_string =&gt; [] =&gt; 'string' );

1;
</pre>

<pre style="border: 1px solid lightgray; margin: 10px; padding: 10px; white-space: pre-wrap; " class="console">
% <b style="color: white;">prove -lvm t</b>
t/lzma_example.t ..
# Seeded srand with seed '20170611' from local date.
ok 1 - returns a version
# version = 5.2.3
1..1
ok
All tests successful.
Files=1, Tests=1,  1 wallclock secs ( 0.03 usr  0.00 sys +  0.25 cusr  0.01 csys =  0.29 CPU)
Result: PASS
</pre>

Now I also mentioned that some Aliens can be used as tool oriented Alien modules.  Alien::xz 
is an example of a hybrid Alien which can be used as a library oriented Alien (it provides 
liblzma) and as a tool oriented Alien (it provides the `xz` command line tool).  Some Aliens, 
like M<Alien::gmake> are tool oriented Aliens only, that is they provide a tool, but not 
library.  Just to show how easy it is to use, lets write the same example module using the 
tool oriented mode:

<center><pre style="margin: 10px 10px 0 10px; padding: 10px; background-color: blue; color: white; ">
lib/LZMA/Example.pm (Tool)
</pre></center>
<pre style="border: 1px solid lightgray; margin: 0 10px 10px 10px; padding: 10px; " class="sh_perl">
package LZMA::Example;

use strict;
use warnings;
use Capture::Tiny qw( capture );
use Alien::xz;
use Env qw( @PATH );
use base qw( Exporter );

our $VERSION = '0.01';
our @EXPORT = qw( lzma_version_string );

unshift @ENV, Alien::xz-&gt;bin_dir;

sub lzma_version_string
{
  my $out = capture { system 'xz', '--version' };
  my($version) = $out =~ /liblzma ([0-9.]+)/;
  $version;
}

1;
</pre>

<pre style="border: 1px solid lightgray; margin: 10px; padding: 10px; white-space: pre-wrap; " class="console">
% <b style="color: white;">prove -lvm t</b>
t/lzma_example.t ..
# Seeded srand with seed '20170611' from local date.
ok 1 - returns a version
# version = 5.2.2
1..1
ok
All tests successful.
Files=1, Tests=1,  0 wallclock secs ( 0.02 usr  0.00 sys +  0.13 cusr  0.00 csys =  0.15 CPU)
Result: PASS
</pre>

Alien::xz (and all modules that use Alien::Base) provides a `bin_dir` method, which returns 
the path to the tool if it is not already in the path, or empty list if the tool is already in 
the path.  This means that once unshifted onto PATH, we can call it like any other command 
line tool.  Some tools may have different names depending on the platform or the environment.  
Alien::gmake, for example, provides GNU Make, which may be called either `gmake` or `make`.  
It provides an `exe` method to tell you what the name is locally.

So, as you can see in the Perl TMTOWTDI spirit, there are many different ways to utilize an 
Alien module built using M<alienfile> + M<Alien::Build> + M<Alien::Base>.  There are some 
other systems out there like M<Module::Install> (MI) that I didn't demonstrate.  Because MI is 
not being actively developed any longer and EUMM is preferred for new development, there may 
be some out there using this older technology that could benefit from Alien.  Or some other 
technology that I haven't thought of using with Alien yet.  If you are one of those people 
please do feel free to stop on by the #native channel on irc.perl.org, or open an issue on the
[Alien::Build issue tracker](https://github.com/plicease/Alien-Build/issues).
I have added the full working examples demonstrated here (with all the necessary support 
files) to the `example/user` directory in M<Alien::Build>.
I have also written a manual on using Alien::Base based Aliens here: 
M<Alien::Build::Manual::AlienUser>.  Next time I will demonstrate some specialized features, 
like how to use an Alien as a fallback prerequisite.

---

This article was originally posted to [blogs.perl.org](https://blogs.perl.org):
[here](http://blogs.perl.org/users/graham_ollis/2017/06/the-many-ways-to-use-alien.html)
