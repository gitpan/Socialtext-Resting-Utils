#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 1;

my $script = "bin/wikedit";
like qx($^X -Ilib -c $script 2>&1), qr/syntax OK/, "$script compiles ok";
