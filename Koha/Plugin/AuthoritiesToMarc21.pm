package Koha::Plugin::AuthoritiesToMarc21;

## It's good practive to use Modern::Perl
use Modern::Perl;

## Required for all plugins
use base qw(Koha::Plugins::Base);

## We will also need to include any Koha libraries we want to access
use Data::Dump qw(dump);

use Koha::Upload;
use MARC::Moose::Formater::AuthorityUnimarcToMarc21;
use MARC::Moose::Parser::Iso2709;

## Here we set our plugin version
our $VERSION = 1.00;

## Here is our metadata, some keys are required, some are optional
our $metadata = {
    name   => 'Convert Authorities MARC',
    author => 'Vassilis Kanellopoulos',
    description =>
'This plugin converts Authorities from UNIMARC to MARC21.',
    date_authored   => '2015-10-09',
    date_updated    => '2015-12-09',
    minimum_version => undef,
    maximum_version => undef,
    version         => $VERSION,
};

## This is the minimum code required for a plugin's 'new' method
## More can be added, but none should be removed
sub new {
    my ( $class, $args ) = @_;

    ## We need to add our metadata here so our base class can access it
    $args->{'metadata'} = $metadata;
    $args->{'metadata'}->{'class'} = $class;

    ## Here, we call the 'new' method for our base class
    ## This runs some additional magic and checking
    ## and returns our actual $self
    my $self = $class->SUPER::new($args);

    return $self;
}

sub uninstall { return 1; }

sub tool {
    my ( $self, $args ) = @_;
    my $cgi = $self->{'cgi'};

    unless ( $cgi->param('submitted') ) {
        $self->tool_step1();
    } else {
       $self->tool_step2();
    }

}

sub tool_step1 {
    my ( $self, $args ) = @_;
    my $cgi = $self->{'cgi'};
    my $template = $self->get_template({ file => 'tool-step1.tt' });

    print $cgi->header();
    print $template->output();
}

sub tool_step2 {
    my ( $self, $args ) = @_;
    my $cgi = $self->{'cgi'};
    my $template = $self->get_template({ file => 'tool-step2.tt' });

    my $fileID = $cgi->param('uploadedfileid');

    if($fileID) {
        my $upload = Koha::Upload->new->get({ id => $fileID, filehandle => 1 });
        my $fh = $upload->{fh};
        my $filename = $upload->{name}; # filename only, no path
        my $marcrecord= '';
        $/ = "\035";
        while (<$fh>) {
            s/^\s+//;
            s/\s+$//;
            $marcrecord.=$_;
        }
        $fh->close;
        my $toMarc21Formater = MARC::Moose::Formater::AuthorityUnimarcToMarc21->new();
        my $marc21 = $toMarc21Formater->format($iso2709Parser->parse($marcrecord));
        # should download unimarc file
    }

    print $cgi->header();
    print $template->output();
}

1;
