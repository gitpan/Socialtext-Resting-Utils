package Socialtext::WikiObject;
use strict;
use warnings;
use Carp;

=head1 NAME

Socialtext::WikiObject - Represent wiki markup as a data structure and object

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

  use Socialtext::WikiObject;
  my $page = Socialtext::WikiObject->new(
                rester => $Socialtext_Rester,
                page => $wiki_page_name,
             );

=head1 DESCRIPTION

Socialtext::WikiObject is a package that attempts to fetch and parse some wiki
text into a perl data structure.  This makes it easier for tools to access
information stored on the wiki.

The wiki data is parsed into a data structure intended for easy access to the
data.  Headings, lists and text are supported.  Tables are not currently
parsed.

Subclass Socialtext::WikiObject to create a custom module for your data.  You
can provide accessors into the parsed wiki data.  

Subclasses can simply provide accessors into the data they wish to expose.

=head1 FUNCTIONS

=head2 new( %opts )

Create a new wiki object.  Options:

=over 4

=item rester

Users must provide a Socialtext::Resting object setup to use the desired 
workspace and server.

=item page

If the page is given, it will be loaded immediately.

=back

=cut

sub new {
   my ($class, %opts) = @_;
   croak "rester is mandatory!" unless $opts{rester};

   my $self = { %opts };
   bless $self, $class;
   
   $self->load_page if $self->{page};
   return $self;
}

=head2 load_page( $page_name )

Load the specified page.  Will fetch the wiki page and parse
it into a perl data structure.

=cut

sub load_page {
    my $self = shift;
    my $page = $self->{page} = shift || $self->{page};
    croak "Must supply a page to load!" unless $page;
    my $rester = $self->{rester};
    my $wikitext = $rester->get_page($page);
    return unless $wikitext;

    my $current_heading;
    my @parent_stack;
    my $base_obj = $self;
    my $heading_level_start;
    for my $line (split "\n", $wikitext) {
	next if $line =~ /^\s*$/;

        # Header line
	if ($line =~ m/^(\^\^*)\s+(.+?):?\s*$/) {
            $heading_level_start = length($1) if !defined $heading_level_start;
	    my $heading_level = length($1 || '') - $heading_level_start;
	    my $new_heading = $2;
	    while (@parent_stack > $heading_level) {
                # Down a header level
                pop @parent_stack;
	    }
	    if ($heading_level > @parent_stack) {
                # Up a level - create a new node
		push @parent_stack, $current_heading;
		my $old_obj = $base_obj;
		$base_obj = { name => $current_heading };
                $base_obj->{text} = $old_obj->{$current_heading} 
                    if $current_heading and $old_obj->{$current_heading};

                # update previous base' - @items and direct pointers
		push @{ $old_obj->{items} }, $base_obj;
		$old_obj->{$current_heading} = $base_obj;
		$old_obj->{lc($current_heading)} = $base_obj;
	    }
	    else {
		$base_obj = $self;
		for (@parent_stack) {
		    $base_obj = $base_obj->{$_} || die "Can't find $_";
		}
	    }
	    $current_heading = $new_heading;
	}
        # Lists
	elsif ($line =~ m/^[#\*]\s+(.+)/) {
	    my $item = $1;
	    my $field = $current_heading || 'items';
	    if (! exists $base_obj->{$field}) {
		push @{ $base_obj->{$field} }, $item;
	    }
	    elsif (ref($base_obj->{$field}) eq 'ARRAY') {
		push @{ $base_obj->{$field} }, $item;
	    }
	    elsif (ref($base_obj->{$field}) eq 'HASH') {
		push @{ $base_obj->{$field}{items} }, $item;
	    }
	    elsif ($base_obj->{$field}) {
                my $text = $base_obj->{$field};
		$base_obj->{$field} = { 
                    text => $text, 
                    items => [ $item ],
                };
	    }
	    $base_obj->{lc($field)} = $base_obj->{$field};
	}
        # Text under a heading
	elsif ($current_heading) {
	    $base_obj->{$current_heading} .= "$line\n";
	    $base_obj->{lc($current_heading)} = $base_obj->{$current_heading};
	}
        # Text without a heading
        else {
            $base_obj->{text} .= "$line\n";
        }
    }
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
