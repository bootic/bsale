require 'net/http'
require 'json'
require "bsale/version"

module Bsale
  # Basic Bsale client
  #
  # client = Bsale::Client.new('someaccesstoken')
  # products = client.get('products.json')
  # products.count # 4
  # products.limit # 25
  # products.to_h # full hash resource
  # products.items # [<Bsale::Entity...>, <Bsale::Entity ..>]
  # products.items.map(&:id) # [1,2,3, etc]
  # # follow hrefs, makes new GET request
  # product = products.items.follow
  # product.id # 1
  # new_product = client.post('products', name: 'new product')
  # r = client.delete(product.href)
  # r._status # 204
  #
  class Client
    UA = "Bootic Bsale Client v1 - #{RUBY_VERSION} #{RUBY_PLATFORM}".freeze
    JSON_MIME = 'application/json'.freeze
    BASE_URL = 'https://api.bsale.cl/v1'.freeze

    def initialize(token)
      @token = token
    end

    def get(path)
      request(path)
    end

    def post(path, payload = {})
      request(path, method: Net::HTTP::Post) do |req|
        req.body = JSON.generate(payload)
      end
    end

    def put(path, payload = {})
      request(path, method: Net::HTTP::Put) do |req|
        req.body = JSON.generate(payload)
      end
    end

    def delete(path)
      request(path, method: Net::HTTP::Delete)
    end

    def request(path, method: Net::HTTP::Get, &block)
      url = path.to_s =~ /^http/ ? path : [BASE_URL, path].join('/')
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = method.new(uri.request_uri)
      request['Content-Type'] = JSON_MIME
      request['User-Agent'] = UA
      request['access_token'] = @token
      yield(request) if block_given?

      response = http.request(request)
      body = response.body.to_s.strip == '' ? {} : JSON.parse(response.body, symbolize_names: true)
      Entity.new(
        data: body,
        status: response.code,
        client: self,
      )
    end

    class Entity
      attr_reader :_status
      def initialize(data: {}, status: 200, client:)
        @_data, @_status, @_client = data, status.to_i, client
        @_cache = {}
      end

      def follow
        if _data[:href]
          _client.request(_data[:href])
        else
          self
        end
      end

      def method_missing(method_name, *args, &block)
        super if args.any? || block_given?
        mname = method_name.to_sym
        super unless _data.key?(mname)

        if _cache.key?(mname)
          _cache[mname]
        else
          _cache[mname] = wrap(_data[mname])
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        _data.key?(method_name.to_sym)
      end

      def inspect
        %(<#{self.class.name} [#{_data.keys.join(', ')}]>)
      end

      def to_h
        _data
      end

      def has?(key)
        _data.key key.to_sym
      end

      private
      attr_reader :_data, :_client, :_cache

      def wrap(value)
        case value
        when Hash
          self.class.new(data: value, client: _client)
        when Array
          value.map{|v| wrap(v) }
        else
          value
        end
      end
    end
  end
end
