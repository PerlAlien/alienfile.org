use Test2::V0;
use Text::Markdown::Custom qw( markdown );

imported_ok 'markdown';

is(
  markdown("\n```\nuse strict;\nuse warnings;\n```\n"),
  "<p><code>\nuse strict;\nuse warnings;\n</code></p>\n",
);

is(
  markdown("\n```perl\nuse strict;\nuse warnings;\n```\n"),
  "<p><pre class=\"sh_perl\">use strict;\nuse warnings;\n</pre></p>\n",
);

is(
  markdown("M<PerlX::Define>"),
  "<p><a href=\"https://metacpan.org/pod/PerlX::Define\" class=\"module\">PerlX::Define</a></p>\n",
);

done_testing;
