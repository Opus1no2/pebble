# frozen_string_literal: true
require_relative "pebble/version"

module Pebble
  TOP_LEVEL_BINDING = binding unless defined?(TOP_LEVEL_BINDING)
  @route_table = {}

  class << self
    def routes(&block)
      routes = Hash.new { |h, k| h[k] = {} }

      define_singleton_method(:define_route) do |method, path, ref|
        routes[method][path] = resolve(ref)
      end

      define_singleton_method(:get)    { |path, ref| define_route("GET", path, ref) }
      define_singleton_method(:post)   { |path, ref| define_route("POST", path, ref) }
      define_singleton_method(:put)    { |path, ref| define_route("PUT", path, ref) }
      define_singleton_method(:delete) { |path, ref| define_route("DELETE", path, ref) }

      instance_eval(&block)

      @route_table.merge!(routes)
    end

    def resolve(handler_ref)
      case handler_ref
      when Symbol
        TOP_LEVEL_BINDING.eval("method(:#{handler_ref})")
      when Proc
        handler_ref
      else
        raise ArgumentError, "Invalid handler reference: #{handler_ref.inspect}"
      end
    end

    def run
      -> (env) do
        path = env['PATH_INFO']
        method = env['REQUEST_METHOD']

        handler = @route_table.dig(method, path)
        return [404, { "content-type" => "text/plain" }, ["Not Found"]] unless handler

        response = handler.call
        [200, { "content-type" => "text/plain" }, [response]]
      end
    end
  end
end
