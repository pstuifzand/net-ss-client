package Net::SS::Client::Role::Update;
use Moo::Role;

requires 'query';

sub update {
    my ($self, $uri) = @_;
    my %args = (
        method    => 'POST',
        uri       => $uri,
        need_body => 1,
    );
    return $self->query(%args);
}

1;

