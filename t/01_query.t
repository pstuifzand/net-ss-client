use Test::More;
use Net::SS::Client;

my $client = Net::SS::Client->new(
    api_endpoint => 'http://example.com/api/',
);

{
    my $q = $client->get('product/1');
    is($q->request->method, 'GET');
    is($q->request->uri, 'http://example.com/api/product/1');
}

{
    my $q = $client->list('product');
    is($q->request->method, 'GET');
    is($q->request->uri, 'http://example.com/api/product');
}

{
    my $q = $client->delete('product/1');
    is($q->request->method, 'DELETE');
    is($q->request->uri, 'http://example.com/api/product/1');
}

{
    my $q = $client->create('product');
    is($q->request->method, 'POST');
    is($q->request->uri, 'http://example.com/api/product');
    ok($q->need_body);
}

{
    my $q = $client->update('product/1');
    is($q->request->method, 'POST');
    is($q->request->uri, 'http://example.com/api/product/1');
    ok($q->need_body);
}

done_testing();

