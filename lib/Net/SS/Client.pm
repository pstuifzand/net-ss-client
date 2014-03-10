package Net::SS::Client;
use 5.14.2;
use Moo;
use Carp;
use JSON;
use URI;
use URI::QueryParam;
use Net::SS::Query;
use LWP::UserAgent;

with qw/
    Net::SS::Client::Role::Get
    Net::SS::Client::Role::List
    Net::SS::Client::Role::Create
    Net::SS::Client::Role::Update
    Net::SS::Client::Role::Delete
/;

our $VERSION = '0.1.1';

has api_key      => (is => 'ro');
has api_endpoint => (
    is     => 'ro',
    coerce => sub {
        if ($_[0] !~ m{/$}) {
            $_[0] .= '/';
        }
        return URI->new($_[0]);
    },
);

has ua => (
    is => 'lazy',
);
sub _build_ua {
    my $self = shift;
    my $ua = LWP::UserAgent->new(agent => __PACKAGE__ . '/' . $VERSION);
    $ua->credentials($self->api_endpoint->host_port, 'Webwinkel API', $self->api_key, '');
    return $ua;
}

has content_type => (
    is      => 'ro',
    lazy    => 1,
    default => 'application/json',
);

has decoder => (
    is   => 'lazy',
);
sub _build_decoder {
    my $self = shift;
    return JSON->new->utf8;
}

sub create_request_uri {
    my ($self, $uri) = @_;
    return URI->new_abs($uri, $self->api_endpoint)
}

sub request {
    my ($self, $req) = @_;
    my $res = $self->perform_request($req);

    if ($res->is_success) {
        return $self->handle_success($req, $res);
    }
    if ($res->is_error) {
        return $self->handle_error($req, $res);
    }
    return;
}

sub create_request {
    my ($self, $method, $uri) = @_;
    my $abs_uri = $self->create_request_uri($uri);
    return HTTP::Request->new($method, $abs_uri);
}

sub perform_request {
    my ($self, $req) = @_;
    return $self->ua->request($req);
}

sub handle_error {
    my ($self, $req, $res) = @_;
    if ($res->code == 400) {
        return $self->decoder->decode($res->decoded_content);
    }
    elsif ($res->code == 404) {
        return;
    }
    croak 'Unhandled HTTP response: ' . $res->status_line . "\n" . $req->as_string;
    return;
}

sub handle_success {
    my ($self, $req, $res) = @_;
    if ($res->code == 200) {
        my $content = $res->decoded_content;
        if ($content) {
            return $self->decoder->decode($content);
        }
        return {};
    }
    elsif ($res->code == 201) {
        return $res->header('Location');
    }
    croak 'Unhandled HTTP response: ' . $res->status_line;
}

sub query {
    my ($self, %args) = @_;
    return Net::SS::Query->new(%args, client => $self);
}

1;

=head1 NAME

Net::SS::Client - Basic API client

=head1 AUTHOR

Peter Stuifzand <peter@stuifzand.eu>

=head1 LICENSE
 
 This library is free software and may be distributed under the same terms
 as perl itself. See L<http://dev.perl.org/licenses/>.
  
=cut

