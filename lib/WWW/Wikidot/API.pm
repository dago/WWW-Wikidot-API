package WWW::Wikidot::API;

use Mouse;
use RPC::XML;
use RPC::XML::Client;
use WWW::Wikidot::API::File;
use WWW::Wikidot::API::Page;

=head1 NAME

WWW::Wikidot::API - The great new WWW::Wikidot::API!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

This module provides wrapper functions for the Wikidot API as described in
  http://www.wikidot.com/doc:api-methods
and tries to both resemble the API functions closely but also keep the usage as easy and perlish as possible.


    use WWW::Wikidot::API;

    my $wd = WWW::Wikidot::API->new();
    ...

=head1 SUBROUTINES/METHODS

=head2 new( site => 'mysite', user => 'myself', password => 'secret42' )

Creates a new object to access the Wikidot site 'mysite' as user 'myself' with
the password 'secret42'.

=cut

has 'site'     => ( is => 'rw', isa => 'Str', required => 1 );
has 'user'     => ( is => 'rw', isa => 'Str', required => 1 );
has 'password' => ( is => 'rw', isa => 'Str', required => 1 );
has '_cli'     => ( is => 'rw', isa => 'RPC::XML::Client' );

sub url {
  my $self = shift;
  return 'https://' . $self->user . ':' . $self->password . '@www.wikidot.com/xml-rpc-api.php';
}

sub BUILD {
  my $self = shift;
  $self->_cli( RPC::XML::Client->new( $self->url ) );
}

# Issue an XMLRPC request

sub _request {
  my ($self, $func, @args) = @_;

  my $req = RPC::XML::request->new( $func, @args );
  my $resp = $self->_cli->send_request( $req );

#use Data::Dumper;
#print Dumper( $resp );

  # XXX: Check for errors

  return $resp->value;
}
  
=head2 categories

Returns the list of categories.

=cut

sub categories {
  my $self = shift;

  my $resp = $self->_request( 'categories.select', { site => $self->site } );
  my @categories = @$resp;

  return @categories;
}

=head2 files( page => <pagename> )

Return the list of names for the files associated with the specified page.

=cut

sub files {
  my ($self, %args) = @_;

  confess( "Mandatory parameter 'page' is missing" ) if( !exists $args{page} );

  my $resp = $self->_request( 'files.select', { site => $self->site, page => $args{page} } );
  my @files = @$resp;

  return map { WWW::Wikidot::API::File->new( _site => $self, page => $args{page}, filename => $_ ) } @files
}

=head2 pages

Optional args:
  prefetch => 1  Prefetches the metadata for all pages

Returns a list of the pages.

=cut

sub pages {
  my ($self, %args) = @_;

  my $resp = $self->_request( 'pages.select', { site => $self->site } );
  my @pages = @$resp;

  my %meta;
  if( $args{prefetch} ) {
    my @todo = @pages;
    while( @todo ) {
      $resp = $self->_request( 'pages.get_meta', {
        site => $self->site,
        pages => [ splice( @todo, 0, 10 ) ],
      } );
      @meta{keys %$resp} = values %$resp;
    }
  }
  
  return map { WWW::Wikidot::API::Page->new( _site => $self, page => $_, (exists $meta{$_} ? (_meta => $meta{$_}) : ()), ) } @pages
}

=head2 tags

Optional:
  pages => [ <page1>, <page2>, ...]     Restrict to tags from these pages
  categories => [ <cat1>, <cat2>, ...]  Restrict to tags of the pages from these categories

Returns the list tags assigned to the specified pages.

=cut

sub tags {
  my ($self, %args) = @_;

  my $categories = $args{categories};
  my $pages = $args{pages};

  my %tags;
  do {
    my $resp = $self->_request( 'tags.select', { site => $self->site,
      ($categories ? (categories => $categories) : ()),
      ($pages ? (pages => [ splice( @$pages, 0, 10 ) ]) : ()),
    } );
    $tags{$_} = 1 foreach (@$resp);
  } while( $pages && @$pages > 0 );

  return keys %tags;
}

sub page {
  my ($self, %args) = @_;
  my $name = $args{name};

  my $resp = $self->_request( 'pages.get_one', { site => $self->site, page => $name } ); 
  my %page = %$resp;

  return %page;
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
