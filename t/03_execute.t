use Test::More;
use Net::SS::Client;

my $client = Net::SS::Client->new(
    api_endpoint => 'http://example.com/api/',
);

Moo::Role->apply_roles_to_object($client, 'Net::SS::Client::Test');

{
    ok(!$client->requested);
    my $p = $client->get('product/1')->execute;
    ok($client->requested);
    is($p->{name}, 'Product');
    is($p->{price}, '100');
}


done_testing();

