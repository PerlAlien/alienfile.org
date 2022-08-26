## Improved reliability with Alien and Test::Alien

By <b>Graham Ollis</b> on 20 January 2016

The one major platform that didn’t work on the initial switch was of 
course Strawberry Perl, but after some debugging and patches I got 
M<Alien::Hunspell> and M<Text::Hunspell> to work there as well.  I even 
submitted patches to upstream to the hunspell project, which were 
accepted, so that in the future less patching will be required.  This is 
what is great about Open Source when it works.

The results as recorded in the cpantesters matrix are stark:

  * <a href="http://matrix.cpantesters.org/?dist=Text-Hunspell%202.14">2.14 - the first version to insist in its Makefile.PL on a version of Alien::Hunspell that works on Windows</a>
  * <a href="http://matrix.cpantesters.org/?dist=Text-Hunspell%202.11">2.11 - the last version to use ExtUtils::PkgConfig</a>

In the process of working on all of this I finally gave up on 
M<Test::CChecker>.  I wrote this module to test Alien distributions, and 
leveraged some capabilities from M<ExtUtils::CChecker>, which is designed 
to probe and check compiler and linker flags from a Makefile.PL or 
Build.PL file.

M<Test::CChecker> was a huge improvement over existing state of affairs for 
testing Aliens when I wrote it.  For most such modules, this consisted 
of the hand rolled .t files that used the Config module and attempted to 
build executables by invoking the compiler via system or qx.  Assuming 
that an Alien module even had any tests.  Here is a simplified version 
of the M<Test::CChecker> test that I wrote for M<Alien::Hunspell>.

<pre class="sh_perl">
use Test::More;
use Alien::Hunspell;
use Test::CChecker 0.07;

plan tests => 2;

compile_output_to_note;

compile_with_alien 'Alien::Hunspell';

my $source = do { local $/; <DATA> };

compile_ok $source, 'basic compile test';

compile_run_ok $source, "basic compile/link/run test";

__DATA__
#include <hunspell.h>

int
main(int argc, char *argv[])
{
  Hunhandle *h;

  h = Hunspell_create("","");
  Hunspell_destroy(h);

  return 0;
}
</pre>

What this does is compile and link an executable using the flags 
provided by M<Alien::Hunspell>.  It then runs it and ensures that it 
doesn’t dump core, and returns a successful exit status.  Simple(ish) 
for Alien right?  The problem is that there are a number of subtle edge 
cases that become much more prominent when you are installing an Alien 
module that decides that it needs to build the upstream package from 
source.  The biggest difference between what this test tests, and how 
the Alien module is actually used is that M<Text::Hunspell> creates a 
dynamic library and links it to the running Perl process.  This means 
that the test file catches errors specific to linking executables that 
aren’t pertinent to usage in Perl.  It also means that this test file 
does NOT catch errors that are specific to dynamic libraries, which ARE 
pertinent to usage in Perl.

So I wrote M<Test::Alien> to test M<Alien> modules in the way that they 
are actually used.  Create an interface to make it easy to create a 
mini-XS or FFI and run some basic tests like ensure you can query the 
version number.  This increases the likelihood that the Alien module 
will actually be useful dramatically, and it catches errors with the 
Alien module where they should be found, in the Alien module itself, not 
in the downstream XS or FFI module.  Here are simplified tests, also for 
M<Alien::Hunspell>:

<pre class="sh_perl">
# test for XS
use Test::Stream -V1;
use Test::Alien;
use Alien::Hunspell;

plan 3;

alien_ok 'Alien::Hunspell';

my $xs = do { local $/; <DATA> };

xs_ok { xs => $xs, verbose => 1 }, with_subtest {
  my $ptr = My::Hunspell::Hunspell_create("t/supp.aff","t/supp.dic");
  ok $ptr, "ptr = $ptr";
  My::Hunspell::Hunspell_destroy($ptr);
  ok 1, "did not crash";
};

__DATA__

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <hunspell/hunspell.h>

MODULE = My::Hunspell PACKAGE = My::Hunspell

void *
Hunspell_create(affpath, dpath);
    const char *affpath;
    const char *dpath;

void
Hunspell_destroy(handle);
    void *handle;
</pre>

This tests that a basic dynamic extension can be built, and can create 
and destroy a simple hunspell instance without crashing.

<pre class="sh_perl">
# test for FFI
use Test::Stream -V1;
use Test::Alien;
use Alien::Hunspell;

plan 3;

alien_ok 'Alien::Hunspell';

ffi_ok { symbols => [qw( Hunspell_create Hunspell_destroy )] }, with_subtest {
  my($ffi) = @_;

  plan 2;

  $ffi->attach(Hunspell_create => ['string','string'] => 'opaque');
  my $ptr = Hunspell_create("t/supp.aff", "t/supp.dic");

  ok $ptr, "ptr = $ptr";

  $ffi->attach(Hunspell_destroy => ['opaque'] => 'void');
  Hunspell_destroy($ptr);

  ok 1, "did not crash";
};
</pre>

M<Test::Alien> also has tests for tool oriented Alien modules, such as 
M<Alien::gmake> and M<Alien::patch>.  M<Test::Alien> is designed to work 
seamlessly with M<Alien::Base> based M<Alien> modules, but can also be made to 
work without much additional work with non M<Alien::Base> based M<Aliens>.

The other nice thing about the M<Test::Alien> interface is that its tests 
will self skip if a compiler or M<FFI::Platypus> are not found.  This is 
useful, as M<Text::Hunspell::FFI> can use M<Alien::Hunspell> without a 
compiler if the hunspell system packages are installed, and conversely 
M<Text::Hunspell> can use M<Alien::Hunspell> if M<FFI::Platypus> is not 
installed.

I used M<Test::Alien> in development versions of M<Alien::Hunspell> to 
identify and correct bugs to make it more reliable.

---

This article was originally posted to [blogs.perl.org](https://blogs.perl.org):
[here](http://blogs.perl.org/users/graham_ollis/2016/01/improved-reliability-with-alien-and-testalien.html)
