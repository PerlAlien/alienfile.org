## Alien::Build vs. Alien::Base::ModuleBuild

By <b>Graham Ollis</b> on 23 March 2017

I have been working on the next generation of M<Alien::Base> installer which is called 
M<Alien::Build>.  It is already quite usable, and I encourage it's use for anyone who is 
considering building a new Alien modules.  It may also be useful to migrate existing Aliens, 
if they have requirements that can utilize its unique features.  The main idea is to 
concentrate the recipe for discovery and building of a library into an M<alienfile> which is 
separate from the Perl installer (usually ExtUtils::MakeMaker or Module::Build).  Over the 
next few weeks I intend on writing a little about some of the new features of Alien::Build.  
In the meantime, if you are interested, M<Alien::Build::Manual::AlienAuthor> may help you get 
started.

A year ago I mentioned that we were planning on spinning M<Alien::Base::ModuleBuild> (AB::MB) 
off from the main M<Alien::Base> distribution.  Now that we have a viable alternative, we 
plan to split AB::MB off into its own distribution next week.  Alien::Base will specify 
AB::MB as a prerequisite, until the first of October 2017.  At that time it will be removed 
as a prerequisite and if you are using AB::MB you will need to specify it as a 
configure_requires in your Build.PL.

The main potential breakage for this is that when trying to install an Alien which hasn't 
been fixed, you will receive an error message like this:

`Can't locate Alien/Base/ModuleBuild.pm in @INC`

I think most Perl programmers will know that they need to install AB::MB and this is a very 
minor inconvenience.  In addition, because we have been aggressive about notifying Alien 
developers and providing pull requests there are very few Alien modules that still have this 
bug.  Those that do are not used widely .

We plan on maintaining AB::MB for quite some time, as there is a lot of working code that 
uses it, and works well.

---

This article was originally posted to [blogs.perl.org](https://blogs.perl.org):
[here](http://blogs.perl.org/users/graham_ollis/2017/03/alienbuild-vs-alienbasemodulebuild.html)
