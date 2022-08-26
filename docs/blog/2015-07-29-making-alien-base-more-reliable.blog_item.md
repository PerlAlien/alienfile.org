## Making Alien::Base more reliable

By <b>Graham Ollis</b> on 29 July 2015

The M<Alien::Base> (AB) team has done a number of things over the past 
year with AB to make the installing packages more reliable.  For AB 
based Alien developers who have created their own Alien::Libfoo this is 
great because they get the benefit of more reliable installs when users 
upgrade their version of AB without having to release a new version of 
Alien::Libfoo.  Though largely backward compatible with version 0.005 
(or perhaps further), modern versions of AB have also been given a few 
interface enhancements that require changes in Alien::Libfoo in order to 
benefit.  So if you are an AB based Alien developer, please consider a 
couple of simple changes that you can make to make your distribution 
more reliable.

### Use `%c` instead of `%pconfigure`.

Long story short, the `%p` directive was intended to handle the 
portability problem when running a command in the current directly.  On 
Unix this requires a `./` prefix.  That won’t work on Windows.  
Unfortunately, configure is usually a shell script and on Windows you 
need MSYS (or something similar) to provide sh and friends.  Even if you 
had MSYS, `%pconfigure` won’t correctly invoke configure on Windows, 
because that isn’t how you run a shell script on Windows.  So back in 
version 0.005 we added the `%c` directive to mean “run configure however 
that works on this platform”.  If AB sees that you are using `%c` it 
will also make sure that M<Alien::MSYS> gets added as a build 
requirement, if it is needed.  In many cases, adding Windows support for 
your AB based Alien distribution may be as simple replacing 
`%pconfigure` with `%c` and making AB 0.005 a prerequisite.

### Require Alien::Base 0.018 (or 0.021)

In version 0.016 we introduced staged installs to blib, and in 0.018 we 
made it the default.  This was a significant change so while believed it 
shouldn't break any existing modules, out an abundance of caution, I 
blogged about this a while ago, and included some of the technical 
details:

 * <a href="http://blogs.perl.org/users/graham_ollis/2015/04/alienbase-past-present-and-future-upcoming-change-in-behavior-1.html">http://blogs.perl.org/users/graham_ollis/2015/04/alienbase-past-present-and-future-upcoming-change-in-behavior-1.html</a>

So far, this change has been pretty positive.  The upshot is that the 
cpan tester installs work in the same way as regular installs that users 
make.  This means that the results in your cpan testers matrix is more 
reliable AND more representative as to how users are actually using your 
module.  I strongly recommend that anyone using AB bump the required 
version up to 0.018.  If your package doesn’t use pkg-config consider 
requiring 0.021 which fixed a bug with system libraries that don’t have 
a pkg-config .pc file.

---

This article was originally posted to [blogs.perl.org](https://blogs.perl.org):
[here](http://blogs.perl.org/users/graham_ollis/2015/07/making-alienbase-more-reliable.html)
