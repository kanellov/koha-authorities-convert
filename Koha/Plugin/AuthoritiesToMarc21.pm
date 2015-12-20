package Koha::Plugin::AuthoritiesToMarc21;

use base qw(Koha::Plugins::Base);
use Encode;
use File::Basename;
use Koha::Upload;
use MARC::Moose::Formater::AuthorityUnimarcToMarc21;
use MARC::Moose::Parser::Iso2709;
use MARC::Moose::Reader::File::Iso2709;
use Modern::Perl;

our $VERSION  = 1.00;
our $metadata = {
    name        => 'Convert Authorities MARC',
    author      => 'Vassilis Kanellopoulos',
    description => 'This plugin converts Authorities from UNIMARC to MARC21.',
    date_authored   => '2015-10-09',
    date_updated    => '2015-12-20',
    minimum_version => undef,
    maximum_version => undef,
    version         => $VERSION,
};

sub new {
    my ( $class, $args ) = @_;
    $args->{'metadata'} = $metadata;
    $args->{'metadata'}->{'class'} = $class;
    return $class->SUPER::new($args);
}

sub install { return 1; }

sub uninstall { return 1; }

sub tool {
    my ( $self, $args ) = @_;
    my $cgi = $self->{'cgi'};

    if ( $cgi->param('submitted') ) {
        $self->download_file();
    }
    else {
        $self->tool_form();
    }
}

sub tool_form {
    my ( $self, $args ) = @_;
    my $cgi = $self->{'cgi'};
    my $template = $self->get_template( { file => 'tool-form.tt' } );

    print $cgi->header();
    print $template->output();
}

sub download_file {
    my ( $self, $args ) = @_;
    my $cgi    = $self->{'cgi'};
    my $fileID = $cgi->param('uploadedfileid');
    if ($fileID) {
        my $upload
            = Koha::Upload->new->get( { id => $fileID, filehandle => 1 } );
        my $fh = $upload->{fh};
        $fh->close;
        my $uploadedfilePath         = $upload->{path};
        my $marc21_data              = '';
        my $toMarc21Formater
            = MARC::Moose::Formater::AuthorityUnimarcToMarc21->new();
        my $reader = MARC::Moose::Reader::File::Iso2709->new(
            file => $uploadedfilePath );

        while ( my $unimarc = $reader->read() ) {
            $marc21_data
                .= Encode::encode_utf8(
                $toMarc21Formater->format($unimarc)
                    ->as('AuthorityUnimarcToMarc21')->as('iso2709') );
        }
        my ( $name, $path, $ext ) = fileparse( $upload->{name}, '\..*' );
        print $cgi->header(
            -type       => 'application/octet-stream; charset=utf-8',
            -attachment => $name . '_marc21' . $ext,
        );
        print $marc21_data;
        return 1;
    }
    return 0;
}

1;
