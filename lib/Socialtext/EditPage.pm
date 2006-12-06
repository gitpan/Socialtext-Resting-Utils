package Socialtext::EditPage;
use warnings;
use strict;
use Carp qw/croak/;
use File::Temp;

=head1 NAME

Socialtext::EditPage - Edit a wiki page using your favourite EDITOR.

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Fetch a page, edit it, and then post it.

    use Socialtext::EditPage;

    # The rester is set with the server and workspace
    my $rester = Socialtext::Resting->new(%opts);

    my $s = Socialtext::EditPage->new(rester => $rester);
    $s->edit_page('Snakes on a Plane');

=head1 FUNCTIONS

=head2 new( %opts )

Arguments:

=over 4

=item rester

Users must provide a Socialtext::Resting object setup to use the desired 
workspace and server.

=back

=cut

sub new {
    my ($class, %opts) = @_;
    croak "rester is mandatory!" unless $opts{rester};
    my $self = { %opts };
    bless $self, $class;
    return $self;
}

=head2 C<edit_page( %opts )>

This method will fetch the page content, and then run $EDITOR on the file.
After the file has been edited, it will be put back on the wiki server.

Arguments:

=over 4

=item page

The name of the page you wish to edit.

=item callback

If supplied, callback will be called after the page has been edited.  This
function will be passed the edited content, and should return the content to
be put onto the server.

=item tags 

If supplied, these tags will be applied to the page after it is updated.

=back

=cut

sub edit_page {
    my $self = shift;
    my %args = @_;
    my $page = delete $args{page};
    croak "page is mandatory" unless $page;

    my $rester = $self->{rester};
    my $content = $rester->get_page($page);
    my $new_content = $self->_edit_content($content);

    return if $content eq $new_content;

    $new_content = $args{callback}->($new_content) if $args{callback};

    $rester->put_page($page, $new_content);

    if (my $tags = delete $args{tags}) {
        $tags = [$tags] unless ref($tags) eq 'ARRAY';
        for my $tag (@$tags) {
            $rester->put_pagetag($page, $tag);
        }
    }

    return 1;
}

sub _edit_content {
    my $self = shift;
    my $content = shift;

    my $tmp = new File::Temp();
    print $tmp $content;
    close $tmp or die "Can't write " . $tmp->filename . ": $!";

    system( $ENV{EDITOR}, $tmp->filename );

    open my $fh, $tmp->filename or die "unable to open tempfile: $!\n";
    my $new_content;
    {
        local $/;
        $new_content = <$fh>;
    }

    return $new_content;
}


=head1 AUTHOR

Luke Closs, C<< <luke.closs at socialtext.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-socialtext-editpage at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Socialtext-Resting-Utils>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Socialtext::EditPage

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Socialtext-Resting-Utils>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Socialtext-Resting-Utils>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Socialtext-Resting-Utils>

=item * Search CPAN

L<http://search.cpan.org/dist/Socialtext-Resting-Utils>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Luke Closs, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
