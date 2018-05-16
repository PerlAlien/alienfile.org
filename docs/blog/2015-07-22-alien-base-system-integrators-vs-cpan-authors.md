## Alien::Base: System Integrators vs. CPAN Authors

By <b>Graham Ollis</b> on 22 July 2015

Last week I promised (or threatened depending on your outlook) to talk 
about M<Alien::Base> in the context of system integration and 
distribution packagers.

###Philosophy:

The philosophy for M<Alien::Base> has always been that the system 
library should be used when it is available, and if not, the source code 
for that library can be downloaded and installed for you.  My own 
M<Alien::FFI> (isa M<Alien::Base>) which provides 
[libffi](https://sourceware.org/libffi/), and M<FFI::Platypus> which 
uses it is a good example of the success of this approach as you can see 
from their respective 
[test](http://matrix.cpantesters.org/?dist=Alien-FFI+0.12) 
[matrices](http://matrix.cpantesters.org/?dist=FFI-Platypus+0.3)

M<Alien::Base> is of course trying to keep everyone happy all of the 
time, and everyone knows that is impossible.  System vendors complain 
that M<Alien::Base> has too many dependencies.  Module authors fear that 
using the system library will make it too hard to support their XS 
modules since they could end up linking against almost anything.  These 
perspectives frequently clash and it can be a challenge to maintain 
empathy for other parties when they do.</p>

Yes, M<Alien::Base> has a number of non-core dependencies that don’t do 
much when you simply end up using the system library.  On the other 
hand, many of them, such as Capture::Tiny and URI are useful in their 
own right.  In addition once you’ve gone through the pain of providing a 
package for M<Alien::Base> and its 
dependencies you can use it again for other M<Alien::Base> based 
distributions and the XS modules that use them without having to bug 
their maintainers with patches.  If something in M<Alien::Base> doesn’t 
quite work with your build system, please notify us right away so that 
we can fix it!  We don’t hate you.  We just work in a different 
environment that you and may be unaware of your pain.  As an example, we 
added support for destdir (commonly used when creating Linux binary 
packages) back in version 0.005.  I take responsibility for 
unintentionally breaking that in version 0.017, since we didn’t have a 
test for destdir installs.  Thanks to feedback we’ve fixed that and 
added a test that will make sure that it doesn’t happen again.</p>

<p>Yes, depending on the system library does have its challenges, and it 
makes me personally uneasy to think about all the ways that something 
could go wrong.  On the other hand there are also benefits to using the 
system library, as they are usually optimized for the particular 
environment and will more likely to have security patches applied.  It 
is also good to keep in mind that nobody is asking you to support the 
system library.  That is the responsibility of the system developer.  I 
do ask that you not actively stand in the way of people who DO want to 
support the system library.  If there are known bad versions,
[there is a way to specify a minimum or specific library version](https://metacpan.org/pod/distribution/Alien-Base/lib/Alien/Base/FAQ.pod#How-do-I-specify-a-minimum-or-exact-version-requirement-for-packages-that-use-pkg-config),
which should be good enough in most situations.

<p>Fundamentally, it’s good to assume good faith, until you can prove 
otherwise.  Remember that for a CPAN author using M<Alien::Base> makes 
developing and maintaining Alien distributions easier.  Remember that 
for a system vendor, being able to maintain just one version of a 
library saves time and reduces bugs.</p>

###Technical:

The rest of this entry includes some technical notes that may be useful 
for system vendors, and those that are really interested in Alien.

I mentioned that destdir support was broken in 0.017 (it was fixed again 
in 0.022).  Ironically in most cases you will actually not want to take 
advantage of this feature, since it is only required when building the 
library from source, rather than using the system library.  In the next 
version of M<Alien::Base> I hope to have an interface to make it fail 
when the system library cannot be detected.  This is usually what system 
vendors who provide the library as a separate package will want.  If you 
want to have some say in how this interface is exposed, now is an 
excellent time to make yourself heard:

<a href="https://github.com/Perl5-Alien/Alien-Base/pull/135">https://github.com/Perl5-Alien/Alien-Base/pull/135</a>

M<Alien::Base> based modules should almost never be a run-time 
prerequisite with newer versions of M<Alien::Base>, so long as they use 
the <tt>alien_isoloate_dynamic option</tt>.  This is highly recommended 
as long as your package can be built as a static library, which is 
almost always what you want when you are building an Alien package from 
source for XS.

Disclaimer: the remainder of this entry represents my opinions only, and 
not those of the M<Alien::Base> team.  This is true for everything that 
I write here, but in particular my last two points should be considered 
either unsettled or controversial.

Perl usually has paths for architecture specific and platform 
independent module files. M<Alien::Base> does not install into the 
architecture specific directory by default, even though in most cases it 
does install architecture specific files.  I am not entirely sure that I 
agree this is right, but we weren’t able to achieve consensus on 
changing it.  There is now an option and an environment variable to 
change this behavior. The reason you might want to install into the 
architecture specific path is if you are installing to a non-homogeneous 
environment such as AFS.  Another use case would be if you were creating 
a system package for for a library that isn’t otherwise provided by your 
operating system, and will thus be built by the M<Alien::Base> system 
from source.

Finally, I feel there is some room for slimming the dependencies on 
M<Alien::Base> if people make the case.  If there are some prereqs that 
seem unreasonable, please open a ticket on the project GitHub (I can’t 
guarantee that you won’t be the one to do the actual work so be careful 
what you wish for).  As an example, now that M<Archive::Extract> has 
been removed from the core, it might be worth investigating switching to 
M<Archive::Tar> (still in the core) which should work in most cases and 
pulling in M<Archive::Zip> only when it is needed, which should cover 
virtually all other cases.  The dependency on M<Module::Build> (MB) is 
probably not too popular amongst its MB detractors.  At the moment I 
don’t see a good alternative, but I have some ideas on how to proceed if 
this is important to you.

---

This article was originally posted to [blogs.perl.org](https://blogs.perl.org):
[here](http://blogs.perl.org/users/graham_ollis/2015/07/making-alienbase-more-reliable.html)
