## alienfile.org

This is the source for the [alienfile.org](https://alienfile.org) website.  The
intent is to make this the go to place for information about Perl/Alien, and for
these related Alien projects:

 * Alien::Base
 * [Alien::Base::ModuleBuild](/PerlAlien/Alien-Base-ModuleBuild)
 * Alien::Build
 * alienfile

## Contributing.

 1. Install developer deps with `cpanm --installdeps .`  Note that the build tools for the website XOR are not on cpan, you can download it from [dist.wdlabs.com](https://dist.wdlabs.com).
 2. Edit the .md or .tt files as appropriate.
 3. Do NOT edit the .html files as these are generated.
 4. Run `./build.pl` to generate html and other files.
 5. Test by running `plackup test.psgi` and pointing your browser to the URL provided.
 6. You can also run the regression tests with `prove`.
 7. Open a PR as appropriate.

 Thanks!
