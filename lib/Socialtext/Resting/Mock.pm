package Socialtext::Resting::Mock;
use strict;
use warnings;

=head1 NAME

Socialtext::Resting::Mock - Fake rester

=head1 SYNOPSIS

  my $rester = Socialtext::Resting::Mock->(file => 'foo');

  # returns content of 'foo'
  $rester->get_page('bar');

=cut

our $VERSION = '0.01';

=head1 FUNCTIONS

=head2 new( %opts )

Create a new fake rester object.  Options:

=over 4

=item file

File to return the contents of.

=back

=cut

sub new {
    my ($class, %opts) = @_;
    die "file is mandatory" unless $opts{file};
    die "not a file: $opts{file}" unless -f $opts{file};
    my $self = \%opts;
    bless $self, $class;
    return $self;
}

=head2 get_page( $page_name )

Returns the content of the specified file.

=cut

sub get_page {
    my $self = shift;
    my $page_name = shift;
    warn "Mock rester: returning content of $self->{file} for page ($page_name)\n";
    open(my $fh, $self->{file}) or die "Can't open $self->{file}: $!";
    local $/;
    my $page = <$fh>;
    close $fh;
    return $page;
}

=head2 put_page( $page_name )

Does nothing

=cut

sub put_page { }

=head1 AUTHOR

Luke Closs, C<< <luke.closs at socialtext.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2006 Luke Closs, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
1;
