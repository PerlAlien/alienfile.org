use strict;
use warnings;
use 5.020;
use lib 'lib';
use Pods;

my $pods = Pods->new;
$pods->add_dist('https://cpan.metacpan.org/authors/id/P/PL/PLICEASE/Alien-Build-2.59.tar.gz');
$pods->add_dist('https://cpan.metacpan.org/authors/id/P/PL/PLICEASE/App-af-0.17.tar.gz');
$pods->fs_root->remove_tree;
$pods->generate_html;
