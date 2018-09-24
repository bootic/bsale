# Bsale Client

Basic, generic API client for the Bsale API at https://api.bsale.cl/v1

Hypermedia-based. Follow links in each resource instead of hard-coding URLs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bsale'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bsale

## Usage

```ruby
client = Bsale::Client.new('someaccesstoken')
products = client.get('products.json')
products.count # 4
products.limit # 25
products.to_h # full hash resource
products.items # [<Bsale::Entity...>, <Bsale::Entity ..>]
products.items.map(&:id) # [1,2,3, etc]
# follow hrefs, makes new GET request
product = products.items.follow
product.id # 1
new_product = client.post('products', name: 'new product')
r = client.delete(product.href)
r._status # 204
```

Check API docs to see what entry-point URLs are available.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/bsale.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
