package Net::SS::Query;
use Moo;
use Carp;
use URI;
use Class::Load 'load_class';

has type => (
    is       => 'ro',
    isa      => sub { croak "Should be an identifier" unless $_[0] =~ m/^\w+$/ },
);

has method => (
    is       => 'ro',
    isa      => sub { croak "Unsupported method" unless $_[0] =~ m/^GET|POST|PUT|DELETE$/ },
    required => 1,
);

has uri => (
    is        => 'ro',
    predicate => 1,
    coerce    => sub {
        return URI->new($_[0]) unless ref($_[0]) && $_[0]->isa('ISA');
        return $_[0];
    },
);

has id => (
    is        => 'ro',
    predicate => 1,
);

has body => (
    is        => 'rw',
    predicate => 1,
);

has client => (
    is => 'ro',
);

has request => (
    is   => 'lazy',
);

sub _build_request {
    my $self = shift;
    my $uri = $self->uri;
    return $self->client->create_request($self->method, $uri);
}

has 'need_body' => (
    is       => 'ro',
    required => 1,
);

has class => (
    is        => 'rw',
    predicate => 1,
);

around class => sub {
    my $orig = shift;
    my $self = shift;
    if (@_) {
        $orig->($self, @_);
        load_class($self->class);
        return $self;
    }
    return $orig->($self);
};

sub query {
    my $self = shift;
    $self->request->uri->query_param(@_);
    return $self;
}

around body => sub {
    my $orig = shift;
    my $self = shift;

    if (@_) {
        $orig->($self, @_);
        $self->request->content_type($self->client->content_type);
        $self->request->content($self->client->decoder->encode($self->body));
        return $self;
    }
    return $orig->($self);
};

sub execute {
    my $self = shift;

    if ($self->need_body && !($self->has_body && $self->body)) {
        die "Request needs 'body', but is not set";
    }

    my $res = eval {
        $self->client->request($self->request)
    };
    if ($@) { # Goed idee?
        my $err = $@;
        $err =~ s/\s+at.*$//s;
        croak $err;
    }

    if ($self->has_class) {
        if (ref($res) eq 'ARRAY') {
            return [ map { $self->class->new($_) } @$res ];
        }
        elsif (ref($res) eq 'HASH') {
            return $self->class->new($res);
        }
        die "Don't know what to do with " . $self->class;
    }
    return $res;
}

1;
