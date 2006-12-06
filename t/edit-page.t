#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 9;
use lib 'lib';

BEGIN {
    use_ok 'Socialtext::EditPage';
    use_ok 't::Mock::Rester';
}

# Don't use a real editor
$ENV{EDITOR} = 't/mock-editor.pl';

my $rester = t::Mock::Rester->new;

Regular_edit: {
    $rester->put_page('Foo', 'Monkey');

    my $ep = Socialtext::EditPage->new(rester => $rester);
    $ep->edit_page(page => 'Foo');

    is $rester->get_page('Foo'), 'MONKEY';
}

Edit_no_change: {
    $rester->put_page('Foo', 'MONKEY');

    my $ep = Socialtext::EditPage->new(rester => $rester);
    $ep->edit_page(page => 'Foo');

    # relies on mock rester->get_page to delete from the hash
    is $rester->get_page('Foo'), undef;
}

Edit_with_callback: {
    $rester->put_page('Foo', 'Monkey');

    my $ep = Socialtext::EditPage->new(rester => $rester);
    my $cb = sub { return "Ape\n\n" . shift };
    $ep->edit_page(page => 'Foo', callback => $cb);

    is $rester->get_page('Foo'), "Ape\n\nMONKEY";
}

Edit_with_tag: {
    $rester->put_page('Foo', 'Monkey');

    my $ep = Socialtext::EditPage->new(rester => $rester);
    $ep->edit_page(page => 'Foo', tags => 'Chimp');

    is $rester->get_page('Foo'), 'MONKEY';
    is_deeply $rester->get_pagetags('Foo'), ['Chimp'];
}

Edit_with_tags: {
    $rester->put_page('Foo', 'Monkey');

    my $ep = Socialtext::EditPage->new(rester => $rester);
    my $tags = [qw(one two three)];
    $ep->edit_page(page => 'Foo', tags => $tags);

    is $rester->get_page('Foo'), 'MONKEY';
    is_deeply $rester->{page_tags}{Foo}, $tags;
}
