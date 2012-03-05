package WWW::Wikidot::API::File;

use Mouse;
use MIME::Base64;	# For file decoding

=head1 NAME

WWW::Wikidot::API::File - Wikidot file object

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

This class models a file in Wikidot. It is not meant to be instantiated directly, but only
from method from WWW::Wikidot::API.

=head1 METHODS

=cut

has '_site'    => ( is => 'ro', isa => 'WWW::Wikidot::API', required => 1 );
has 'page'     => ( is => 'ro', isa => 'Str', required => 1 );
has 'filename' => ( is => 'ro', isa => 'Str', required => 1 );

has '_meta' => (
#  traits => ['Hash'],
  isa => 'HashRef[Str]',
  is => 'ro',
  lazy => 1,
  builder => '_get_meta',
#  handles => {
#    map { $_ => [ accessor => $_ ] } (qw(size comment mime_type mime_description uploaded_by uploaded_at download_url))
#  },
);

#has 'size'             => ( is => 'ro', writer => '_set_size',             isa => 'Int', required => 1, lazy => 1, builder => '_get_meta' );
#has 'comment'          => ( is => 'ro', writer => '_set_comment',          isa => 'Str', required => 1, lazy => 1, builder => '_get_meta' );
#has 'mime_type'        => ( is => 'ro', writer => '_set_mime_type',        isa => 'Str', required => 1, lazy => 1, builder => '_get_meta' );
#has 'mime_description' => ( is => 'ro', writer => '_set_mime_description', isa => 'Str', required => 1, lazy => 1, builder => '_get_meta' );
#has 'uploaded_by'      => ( is => 'ro', writer => '_set_uploaded_by',      isa => 'Str', required => 1, lazy => 1, builder => '_get_meta' );
#has 'uploaded_at'      => ( is => 'ro', writer => '_set_uploaded_at',      isa => 'Str', required => 1, lazy => 1, builder => '_get_meta' );
#has 'download_url'     => ( is => 'ro', writer => '_set_download_url',     isa => 'Str', required => 1, lazy => 1, builder => '_get_meta' );

sub size             { my $self = shift; $self->_meta->{size}; }
sub comment          { my $self = shift; $self->_meta->{comment}; }
sub mime_type        { my $self = shift; $self->_meta->{mime_type}; }
sub mime_description { my $self = shift; $self->_meta->{mime_description}; }
sub uploaded_by      { my $self = shift; $self->_meta->{uploaded_by}; }
sub uploaded_at      { my $self = shift; $self->_meta->{uploaded_at}; }
sub download_url     { my $self = shift; $self->_meta->{download_url}; }

sub _get_meta {
  my $self = shift;
  my $resp = $self->_site->_request( 'files.get_meta', { site => $self->_site->site, page => $self->page, files => [ $self->filename ] } );
  return $resp->{$self->filename};
}

sub content {
  my $self = shift;
  my $resp;

#  if( $self->size < 6 * 1024 * 1024 ) {
    $resp = $self->_site->_request( 'files.get_one', { site => $self->_site->site, page => $self->page, file => $self->filename } );
#    my $content = delete $resp->{content};
#    $self->_update_meta( $resp );
  return decode_base64( $resp->{content} );
#  return $resp->{content};
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
