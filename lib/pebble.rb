# frozen_string_literal: true
require 'rack'
require 'singleton'
require_relative "pebble/version"

module Pebble
  class Error < StandardError; end

  class Router
    include Singleton

    def initialize
      @routes = {}
    end

    def add_route(verb, path, &block)
      @routes[verb] ||= {}
      @routes[verb][path] = block
    end

    def find_route(verb, path)
      @routes.dig(verb, path)
    end

    def call(env)
      request = Rack::Request.new(env)
      verb = request.request_method.downcase.to_sym
      path = request.path_info

      if block = find_route(verb, path)
        [200, {}, block.call]
      else
        [404, { "content-type" => "text/plain" }, ["Not Found"]]
      end
    end
  end

  class Application
    attr_reader :response

    def initialize
      @response = Rack::Response.new
    end

    def call(env)
      dup.call!(env)
    end

    def call!(env)
      code, headers, body = self.class.router.call(env)
      @response.status = code
      @response.headers.merge!(headers)
      @response.write(body)
      @response.finish
    end

    def get(path, &block)
      self.class.get(path, &block)
    end

    class << self
      def prototype
        @prototype ||= new
      end

      def call(env)
        synchronize { prototype.call(env) }
      end

      def lock!
        @lock = true
      end

      def lock?
        @lock
      end

      @@mutex = Mutex.new
      def synchronize(&block)
        if lock?
          @@mutex.synchronize(&block)
        else
          yield
        end
      end

      def router
        @router ||= Router.instance
      end

      def get(path, &block)
        router.add_route(:get, path, &block)
      end
    end
  end
end
