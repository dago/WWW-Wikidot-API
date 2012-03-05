package WWW::Wikidot::API::Page;

use Mouse;

=head1 NAME

WWW::Wikidot::API::Page - Wikidot page object

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

This class models a page in Wikidot. It is not meant to be instantiated directly, but only
from method from WWW::Wikidot::API.

=head1 METHODS

=cut

has '_site'    => ( is => 'ro', isa => 'WWW::Wikidot::API', required => 1 );
has 'page'     => ( is => 'ro', isa => 'Str', required => 1 );

has '_meta' => (
  isa => 'HashRef',
  is => 'ro',
  lazy => 1,
  builder => '_get_meta',
  writer => '_set_meta',
);

has '_one' => (
  isa => 'HashRef',
  is => 'ro',
  lazy => 1,
  builder => '_get_one',
);

sub fullname         { my $self = shift; $self->_meta->{fullname}; }
sub created_at       { my $self = shift; $self->_meta->{created_at}; }
sub created_by       { my $self = shift; $self->_meta->{created_by}; }
sub updated_at       { my $self = shift; $self->_meta->{updated_at}; }
sub updated_by       { my $self = shift; $self->_meta->{updated_by}; }
sub title            { my $self = shift; $self->_meta->{title}; }
sub parent_fullname  { my $self = shift; $self->_meta->{parent_fullname}; }
sub tags             { my $self = shift; @{$self->_meta->{tags}}; }
sub revisions        { my $self = shift; $self->_meta->{revisions}; }
sub comments         { my $self = shift; $self->_one->{comments}; }
sub files            { my $self = shift; $self->_one->{files}; }
sub children         { my $self = shift; @{$self->_one->{children}}; }
sub content          { my $self = shift; $self->_one->{content}; }
sub html             { my $self = shift; $self->_one->{html}; }

sub _get_meta {
  my $self = shift;
  my $resp = $self->_site->_request( 'pages.get_meta', { site => $self->_site->site, pages => [ $self->page ] } );
  return $resp->{$self->page};
}

sub _get_one {
  my $self = shift;
  my $resp = $self->_site->_request( 'pages.get_one', { site => $self->_site->site, page => $self->page } );

  # Update meta data, the extra fields won't hurt
  $self->_set_meta( $resp );

  return $resp;
}

=head1 AUTHOR

Dagobert Michelsen, C<< <dam at opencsw.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-wikidot-api at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Wikidot-API>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Wikidot::API


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Wikidot-API>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Wikidot-API>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Wikidot-API>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Wikidot-API/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Dagobert Michelsen.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of WWW::Wikidot::API
