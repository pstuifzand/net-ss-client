package Net::SS::Client::Role::Delete;
use Moo::Role;

requires 'query';

sub delete {
    my ($self, $uri) = @_;
    my %args = (
        method    => 'DELETE',
        uri       => $uri,
        need_body => 0,
    );
    return $self->query(%args)
}

1;

