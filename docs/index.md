# alienfile.org - Home of the Perl Alien Project

The Perl Alien Project is dedicated to making external, non-Perl dependencies available for [CPAN](https://metacpan.org/about) modules.
This is for both libraries (potentially any language) and tools (such as code generators).
To this end the `Alien::` namespace on [CPAN](https://metacpan.org/about) has been reserved for modules that provide such
dependencies.  A well behaved Alien should probe the system to see if the library or tool is already installed.  If not, it should
download it from the internet and install it into a private share location so that it can be used by other Perl modules.
Installing in a private share location is an important part of the Alien philosophy as we do not want to replace or corrupt
system libraries.

The M<original manifesto|Alien#ORIGINAL_MANIFESTO> developed by A<Artur Bergman|ABERGMAN> states that no framework is to be imposed onto
Alien authors, which adds to the flexability of the Alien concept.  That said you should consider the M<Alien::Build> framework,
which provides powerful tools for creating and maintaining Aliens.  It is very easy to build an M<Alien::Build> based
Alien that alienizes a package that uses common build tools like M<autotools|Alien::Build::Plugin::Build::Autoconf>
and M<CMake|Alien::Build::Plugin::Build::CMake>.  It is also extensible through its M<plugin|Alien::Build::Plugin> system
allowing other build systems to be added.  The M<Alien::Build> project also comes with a large and growing manual.  The
manual has three main sections depending on how you need to use M<Alien::Build> and a FAQ.

 * 📖 M<Alien::Build::Manual::AlienAuthor> - for would be authors of new M<Aliens|Alien>
 * 📖 M<Alien::Build::Manual::AlienUser> - for users of an existing M<Alien>
 * 📖 M<Alien::Build::Manual::PluginAuthor> - for developers who want to extend M<Alien::Build> using its plugin system
 * 📖 M<Alien::Build::Manual::FAQ> - the Frequently Asked Questions

## Resources hosted here

 * [🪵 Alien Blog](/blog/)
 * [📖 Alien Documentation](/pod/)
 * [📦 libdontpanic](/dontpanic/)

## Slides

 * 🗣️ The Perl Conference 2022 : [NewFangled - Bringing NewRelic to Perl with Alien and FFI Technology](/slides/newfangled)
 * 🗣️ The Perl Conference 2022 lightning talk : [Bundling Code With FFI::Platypus - How FFI::C::Stat was born](/slides/ffi-stat)

## External Links

 * #️ [#native on irc.perl.org](https://kiwiirc.com/nextclient/#irc://irc.perl.org/#native?nick=mc-guest-?)
 * 🐦 [@AlienPerl](https://twitter.com/AlienPerl) - the official twitter acount of the Perl Alien Project
 * 👽 [PerlAlien organization on GitHub](https://github.com/PerlAlien)
 * 👽 [Alien::Build on metacpan](https://metacpan.org/pod/Alien::Build)
