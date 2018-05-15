## Alien::Base and Module::Build</h2>

By <b>Graham Ollis</b> on 1 March 2016

TL;DR - if you have an M<Alien::Base> based M<Alien> module, please 
update configure_requires so that it depends on 
M<Alien::Base::ModuleBuild> instead of M<Alien::Base>, and (this part is 
key) make a release.

This is technically more correct, and it will also future proof your 
module in the event that M<Alien::Base::ModuleBuild> 
gets spun off from the rest of M<Alien::Base>.  There are 
a number of motivations making such a move.  Please join us on 
[GitHub](https://github.com/Perl5-Alien/Alien-Base/issues/157)
or the
[#native IRC channel](https://chat.mibbit.com/?channel=%23native&server=irc.perl.org)
if are interested in working on the next generation of of M<Alien::Base>.

---

This article was originally posted to [blogs.perl.org](https://blogs.perl.org):
[here](http://blogs.perl.org/users/graham_ollis/2016/03/alienbase-and-modulebuild.html)
