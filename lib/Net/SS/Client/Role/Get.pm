package Net::SS::Client::Role::Get;
use Moo::Role;

requires 'query';

sub get {
    my $self = shift;
    my ($uri) = @_;
    my %args = (
        method    => 'GET',
        need_body => 0,
        uri       => $uri,
    );
    return $self->query(%args);
}

1;

