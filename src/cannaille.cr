require "http/server"
require "json"
require "option_parser"

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

# Point d'entrée principal si exécuté directement
if PROGRAM_NAME == __FILE__
  port = 8080

  # Parser les options de ligne de commande
  OptionParser.parse do |parser|
    parser.banner = "Usage: canaille [options]"
    parser.on("-p PORT", "--port=PORT", "Port to listen on (default: 8080)") { |arg_port| port = arg_port.to_i }
    parser.on("-h", "--help", "Show this help") do
      puts parser
      exit
    end
    parser.invalid_option do |flag|
      STDERR.puts "ERROR: #{flag} is not a valid option."
      STDERR.puts parser
      exit(1)
    end
  end

  # Démarrer le serveur
  server = Canaille::Server.new(port: port)
  server.listen
end
