## Reining In Unruely Aliens

By <b>Graham Ollis</b> on 21 September 2022

When I have talked to Perl developers about the Alien technique, some are
rightly concerned about the security implications of downloading arbitrary
stuff off the internet.  My response to this has always to point out that
if you are installing modules from CPAN then you are doing the same.

In fact the default for one of the most popular cpan clients is to use an
unencrypted http connection to fetch modules off the internet.  The default
for the Perl's in core HTTP client is to not verify server identity making
man in the middle attackes much easier.  There are historical reasons for
these decisions, but overall I think these are examples of how Perl is
increasingly out of step with the rest of the internet.

The team responsible for M<Alien::Build> and M<Alien::Base::ModuleBuild>
plan on making it easier for users to control the security model for
downloading and installing alienized packages for M<Alien>s that use them.
We also plan on changing the default model to err on the side of more
secure.  None of these changes is a substitue for properly auditing
the open source code that you use, if your threat model dictates that.
At the end of the day, although there are a few Perl modules that can
be installed statically, the vast majoirty still rely on executing a
`Makefile.PL' or `Build.PL` which is arbitrary Perl code.

The TL;DR is that if you are an Alien author, or if you are the author
of an M<Alien::Build plugin|Alien::Build::Plugin> you should check to
see if your modules still work when `ALIEN_DOWNLOAD_RULE` is set to
`digest_or_encrypt`, which will soon become the new default.  This
will require that alienized packages be either

* Downloaded using a secure protocol such as `https`
* Checked with a cryptographic signature included in the M<alienfile> (or `Build.PL` for M<Alien::Base::ModuleBuild> based aliens)
* Bundled within the M<Alien> itself.

For more details on the security implications please see
M<Alien::Build::Manual::Secirty>.

I have already gone through all of the plugins that I am aware of and
fixed them.  (Unfortunately even plugins that do not modify the
fetch or download stages of L<Alien::Build> are potentially susceptible
because their tests often need to fake the fetch and download steps
and may do so in a way that seems unsafe to L<Alien::Build>).  I will
also go through all of the aliens that I have control over to make sure
they work with this new default.

None of this completely removes the peril of downloading arbitrary
software off the internet, but it does improve the default security
model, and gives the end user more control over the security model
via the `ALIEN_DOWNLOAD_RULE` environment variable.
