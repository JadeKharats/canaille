require "http/server"
require "json"

module Canaille
  VERSION = "0.1.0"

  # Classe principale du serveur
  class Server
    getter? running : Bool

    def initialize(@address : String = "0.0.0.0", @port : Int32 = 8080)
      @server = HTTP::Server.new do |context|
        response = handle_request(context.request)
        context.response.content_type = "application/json"
        context.response.print response
      end
      @running = false
    end

    def listen
      if @running
        return
      end

      @running = true
      @server.listen(@address, @port)
    end

    def close
      unless @running
        return
      end

      @server.close
      @running = false
    end

    # Gère les requêtes HTTP
    def handle_request(request : HTTP::Request) : String
      case request.method
      when "GET"
        case request.path
        when "/"
          {status: "ok", version: VERSION}.to_json
        else
          {error: "Unknown endpoint"}.to_json
        end
      else
        {error: "Method not allowed"}.to_json
      end
    end
  end
end
