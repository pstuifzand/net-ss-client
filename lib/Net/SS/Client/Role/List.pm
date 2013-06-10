package Net::SS::Client::Role::List;
use Moo::Role;

requires 'query';

sub list {
    my ($self, $uri) = @_;
    my %args = (
        method    => 'GET',
        need_body => 0,
        uri       => $uri,
    );
    return $self->query(%args);
}

1;

