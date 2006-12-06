#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Test::More tests => 8;
use Test::Exception;
use lib 't/lib';
use t::Mock::Rester;
use lib 'lib';

BEGIN {
    use_ok 'Socialtext::WikiObject';
}

my $rester = t::Mock::Rester->new;

my @pages = load_test_data();
for my $p (@pages) {
    $rester->put_page($p->{page}, $p->{page_content});

    my $o = Socialtext::WikiObject->new(
        rester => $rester, 
        page => $p->{page},
    );
    isa_ok $o, 'Socialtext::WikiObject';
    is_deeply $o, $p->{expected}, $p->{page};
}

No_wiki_supplied: {
   throws_ok { Socialtext::WikiObject->new }
             qr/rester is mandatory!/;
}

exit;

sub load_test_data {
    my @data;
    {
        my $text = <<'EOT';
^ Theme:

Initial iteration to get the web interface up on our internal beta server.

^ People:

# lukec - 25h
# pancho - 25h

^ Story Boards:

^^ [SetupApache]

^^^ Tasks:

# install base OS on app-beta (2h)
# install latest Apache2 with mod_perl2 (2h)
# Configure Apache2 to start on boot (1h)

^^ [ModPerl HelloWorld]

^^^ Tasks:

# Create Awesome-App package with hello world handler (1h)
# Install Awesome-App package into system perl on app-beta (1h)
# Configure mod_perl2 to have Awesome::App handler (1h)

^^ [Styled Homepage]

^^^ Tasks:

# Integrate mockups into Awesome-App (1h)
# Update Awesome-App on app-beta (1h)

^ Other Information:

Details go here.

* Bullet one
* Bullet two

EOT
        # Build up the data structure in reverse, as there are several 
        # duplicate nodes
        my $theme = 'Initial iteration to get the web interface up on our '
                   . "internal beta server.\n";
        my $people = [
            'lukec - 25h',
            'pancho - 25h',
        ];
        my $setup_apache_tasks = [
            'install base OS on app-beta (2h)',
            'install latest Apache2 with mod_perl2 (2h)',
            'Configure Apache2 to start on boot (1h)',
        ];
        my $setup_apache = {
            name => '[SetupApache]',
            tasks => $setup_apache_tasks,
            Tasks => $setup_apache_tasks,
        };
        my $mod_perl_tasks = [
            'Create Awesome-App package with hello world handler (1h)',
            'Install Awesome-App package into system perl on app-beta (1h)',
            'Configure mod_perl2 to have Awesome::App handler (1h)',
        ];
        my $mod_perl = {
            name => '[ModPerl HelloWorld]',
            tasks => $mod_perl_tasks,
            Tasks => $mod_perl_tasks,
        };
        my $styled_homepage_tasks = [
            'Integrate mockups into Awesome-App (1h)',
            'Update Awesome-App on app-beta (1h)',
        ];
        my $styled_homepage = {
            name => '[Styled Homepage]',
            tasks => $styled_homepage_tasks,
            Tasks => $styled_homepage_tasks,
        };
        my $storyboards = {
            name => 'Story Boards',
            '[SetupApache]' => $setup_apache,
            '[setupapache]' => $setup_apache,
            '[ModPerl HelloWorld]' => $mod_perl,
            '[modperl helloworld]' => $mod_perl,
            '[Styled Homepage]' => $styled_homepage,
            '[styled homepage]' => $styled_homepage,
            items => [
                $setup_apache,
                $mod_perl,
                $styled_homepage,
            ],
        };
        my $other_info = { 
            text => "Details go here.\n",
            items => [
                'Bullet one',
                'Bullet two',
            ],
        };
        my $page_name = 'data structure correct';
        my $page_data = {
            page => $page_name,
            rester => $rester,
            theme => $theme,
            Theme => $theme,
            People => $people,
            people => $people,
            'Story Boards' => $storyboards,
            'story boards' => $storyboards,
            'Other Information' => $other_info,
            'other information' => $other_info,
            items => [
                $storyboards,
            ],
        };

        push @data, {
            page => $page_name,
            page_content => $text,
            expected => $page_data,
        };
    }

    {
        my $text = <<EOT;
^^ Top of the morning

Alpha Bravo

^^^ Ball Tricks

* Mills Mess
* Rubenstein's revenge

^^^ Club Tricks

* Lazy catch

EOT
        my $ball_tricks = [
            q(Mills Mess),
            q(Rubenstein's revenge),
        ];
        my $club_tricks = [
            q(Lazy catch),
        ];
        my $morning_top = {
            name => 'Top of the morning',
            text => "Alpha Bravo\n",
            'Ball Tricks' => $ball_tricks,
            'ball tricks' => $ball_tricks,
            'Club Tricks' => $club_tricks,
            'club tricks' => $club_tricks,
        };
        my $page_name = 'text with items';
        my $page_data = {
            page => $page_name,
            rester => $rester,
            'Top of the morning' => $morning_top,
            'top of the morning' => $morning_top,
            items => [
                $morning_top,
            ],
        };
        push @data, {
            page => $page_name,,
            page_content => $text,
            expected => $page_data,
        };
    }

    {
        my $text = <<EOT;
Page with no title:

# one
# two
EOT
        my $page_name = 'page with no title';
        my $page_data = {
            page => $page_name,
            rester => $rester,
            text => "Page with no title:\n",
            items => [
                'one',
                'two',
            ],
        };
        push @data, {
            page => $page_name,
            page_content => $text,
            expected => $page_data,
        };
    }
    return @data;
}
