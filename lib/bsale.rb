require 'net/http'
require 'json'
require "bsale/version"
require 'bsale/entity'

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

    def initialize(token, base_url: BASE_URL)
      @token = token
      @base_url = base_url
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
      url = path.to_s =~ /^http/ ? path : [base_url, path].join('/')
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

    private
    attr_reader :base_url
  end
end
