module Bsale
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
