## Alien::Base past, present and future (upcoming change in behavior)

By <b>Graham Ollis</b> on 22 April 2015.

M<Alien::Base> has made a great deal of progress since last September when 
Joel Berger turned over day to day development for the project to the 
then newly created M<Alien::Base> team.  We’ve closed most of the major 
issues and pull requests.  One remaining important issue will hopefully 
be solved soon (I will get to that later; if you are an M<Alien::Base> user 
you may want to skip to <b>The Future</b> below).  Stability and 
reliability has improved to the point where it is good enough to be used 
by real projects.  My own M<FFI::Platypus> depends on M<Alien::Base> tech to 
provide libffi, as an example.  I’d like to see some other projects take 
advantage of M<Alien::Base> as well.

What have we fixed?  A number of things:

 * Builds on Microsoft Windows are now doable, thanks to integration 
   with M<Alien::MSYS> that provides the necessary tools to build autotools 
   based packages

 * Relocation of library directories is now
   supported, including support for DESTDIR and AFS
 
 * Support for 64 bit Perls in hybrid 32/64 bit environments like
   Solaris
   
 * Integration with FFI and Inline based distributions

Why?  A lot of XS developers when they use an external non-CPAN 
dependency will take one of two approaches:

 1. Bundle the dependency with the module
 2. Use M<Devel::CheckLib> to find the library as provided by the operating 
    system

These approaches are somewhat inflexible.  If you bundle the dependency 
then you are increasing the bloat of your distribution.  The bundled 
version may become out of date, allowing bugs and security issues that 
have been fixed upstream to persist in your version.  It also may be 
problematic for integrators.  One distribution developer confided in me 
that his module was unlikely to be integrated into his distribution 
because the bundled C code needed to be reviewed and documented for 
legal issues that would not be a problem if the code wasn’t bundled.  
The distribution already provided the library as a separate package.

If you depend on the operating system to provide the library then you 
have a moral obligation to instruct your user as to how to install that 
dependency, which may be different on different platforms.  If the 
dependency isn’t a common one then you will likely not get any useful 
feedback from cpan testers.  Downstream developers may be reluctant to 
use your module as a dependency since it may not install reliably.

Alien defines a non-Perl or non-CPAN dependency so that it can be used 
by your CPAN distribution.  M<Alien::Base> provides a base class that you 
can use to easily construct these dependencies.  When properly 
configured, an M<Alien::Base> based distribution will use the system 
provided library, and if it can’t be found, attempt to download from the 
Internet and install it into a share directory so that it will not 
interfere with any system packages.

As an example, M<FFI::Platypus> depends on M<Alien::FFI> which will use the 
system libffi if it is usually available, and if not it downloads and 
installs it for you.

### The Future:

The one remaining important issue that I mentioned above has to do with 
the way packages are installed into the share directory.  Historically, 
M<Alien::Base> has installed packages into their final destination when the 
cpan client (or user) runs the ./Build install command.  The problem 
with this is that many cpan testers do not necessarily install the 
modules, preferring instead to add the blib paths to the PERL5LIB.  The 
work around for this was for M<Alien::Base> to attempt to detect such an 
environment and install the package into the blib in just that 
circumstances.  This has improved the reliability of cpan testers, but 
it does mean that cpan testers installs for M<Alien::Base> based 
distributions work in differently in a subtle way.

With recent advances in relocation of packages included in M<Alien::Base>
we can now install into the blib and allow the installer to install 
these files into the final location, just like normal Perl 
distributions.  The current version just released today has this 
capability, but is off by default to maintain backward compatibility.  
In the next version 0.017 we plan to make this the default.  So if you 
are the owner of an M<Alien::Base> based distribution, now would be a great 
time to test this change in behavior.  You can do this by installing the 
development version of M<Alien::Base> 0.016_01, or by explicitly setting 
alien_stage_install to 1 in your Build.PL (or dist.ini the latest 
version of the Alien M<Dist::Zilla> plugin also supports this option).  
Here is an example of how M<Alien::LibYAML> was modified to explicitly set 
this value:

<a href="https://github.com/rsimoes/Alien-LibYAML/commit/2dfe47c0acd33785039d1ad27072a16e4bed98d5">https://github.com/rsimoes/Alien-LibYAML/commit/2dfe47c0acd33785039d1ad27072a16e4bed98d5</a>

You should also make M<Alien::Base> 0.016 a prerequisite for your 
distribution.

If this new behavior is going to break your distribution in a way that 
is not otherwise fixable, you can explicitly set alien_stage_install to 
0, and the old behavior will be maintained, even when M<Alien::Base> 0.017 
is released.  If you decide to do this, please contact the M<Alien::Base>
team, as at some point we would like to deprecate and perhaps even 
remove the old behavior.  Contact us on either GitHub:

<a href="https://github.com/Perl5-Alien/Alien-Base/issues/94">https://github.com/Perl5-Alien/Alien-Base/issues/94</a>

or the M<Alien::Base> mailing list:

<a href="https://groups.google.com/forum/#!forum/perl5-alien">https://groups.google.com/forum/#!forum/perl5-alien</a>

---

This article was originally posted to [blogs.perl.org](https://blogs.perl.org):
[here](http://blogs.perl.org/users/graham_ollis/2015/04/alienbase-past-present-and-future-upcoming-change-in-behavior-1.html)

