require 'spec_helper'
require 'webmock/rspec'

RSpec.describe Bsale::Client do
  it "works" do
    token = 'abc'
    resource = {
      id: 123,
      name: 'foo',
      users: [
        {
          name: 'Joe',
          href: 'https://api.bsale.cl/v1/users/1'
        },
        {
          name: 'Jane',
          href: 'https://api.bsale.cl/v1/users/2'
        }
      ]
    }

    user1 = {
      href: 'https://api.bsale.cl/v1/users/1',
      name: 'Joe',
      id: 111,
      email: 'joe@email.com'
    }

    stub_request(:get, 'https://api.bsale.cl/v1/foo').
      with(headers: {'Content-Type' => 'application/json', 'access_token' => token}).
      to_return(status: 200, body: JSON.generate(resource))

    client = described_class.new(token)

    entity = client.get('foo')

    expect(entity._status).to eq 200
    expect(entity.id).to eq 123
    expect(entity.name).to eq 'foo'
    expect(entity.users.map(&:name)).to eq ['Joe', 'Jane']

    stub_request(:get, 'https://api.bsale.cl/v1/users/1').
      with(headers: {'Content-Type' => 'application/json', 'access_token' => token}).
      to_return(status: 200, body: JSON.generate(user1))

    user = entity.users.first.follow
    expect(user.id).to eq 111
    expect(user.email).to eq 'joe@email.com'

    expect{
      user.foobar
    }.to raise_error NoMethodError

    stub_request(:post, 'https://api.bsale.cl/v1/users/1').
      with(body: JSON.generate(name: "Joe2"), headers: {'Content-Type' => 'application/json', 'access_token' => token}).
      to_return(status: 200, body: JSON.generate(user1))

    userb = client.post(user.href, name: 'Joe2')
    expect(userb.id).to eq 111

    stub_request(:put, 'https://api.bsale.cl/v1/users/1').
      with(body: JSON.generate(name: "Joe2"), headers: {'Content-Type' => 'application/json', 'access_token' => token}).
      to_return(status: 200, body: JSON.generate(user1))

    userb = client.put(user.href, name: 'Joe2')
    expect(userb.id).to eq 111

    stub_request(:delete, 'https://api.bsale.cl/v1/users/1').
      with(headers: {'Content-Type' => 'application/json', 'access_token' => token}).
      to_return(status: 204, body: '')

    userb = client.delete(user.href)
    expect(userb._status).to eq 204
  end
end
