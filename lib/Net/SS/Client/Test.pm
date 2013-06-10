package Net::SS::Client::Test;
use Moo::Role;
use JSON;

has 'requested' => (
    is => 'rw',
);

# Replace perform_request
around perform_request => sub {
    my ($orig, $self, $req) = @_;
    $self->requested(1);
    my $res = HTTP::Response->new(200, "OK", ['Content-Type','application/json'], encode_json({name => 'Product', price => '100'}));
    return $res;
};

1;
