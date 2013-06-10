package Net::SS::Client::Role::Create;
use Moo::Role;

requires 'query';

sub create {
    my ($self, $uri) = @_;
    my %args = (
        method    => 'POST',
        uri       => $uri,
        need_body => 1,
    );
    return $self->query(%args);
}

1;

