require "./spec_helper"

# Classe pour tester le serveur sans démarrer un vrai serveur HTTP
class TestableServer < Canaille::Server
  def test_request(method : String, path : String) : String
    request = HTTP::Request.new(method, path)
    handle_request(request)
  end
end

describe Canaille::Server do
  describe "#initialize" do
    it "not running" do
      server = Canaille::Server.new
      server.running?.should be_false
    end
  end

  describe "#handle_request" do
    server = TestableServer.new

    it "responds to root path" do
      response = server.test_request("GET", "/")
      response_json = JSON.parse(response)

      response_json["status"].as_s.should eq("ok")
      response_json["version"].as_s.should eq(Canaille::VERSION)
    end

    it "returns error for unknown endpoint" do
      response = server.test_request("GET", "/unknown")
      response_json = JSON.parse(response)

      response_json["error"].as_s.should eq("Unknown endpoint")
    end

    it "returns error for unsupported HTTP method" do
      response = server.test_request("POST", "/")
      response_json = JSON.parse(response)

      response_json["error"].as_s.should eq("Method not allowed")
    end
  end
end

# Tests d'intégration facultatifs - à exécuter si nécessaire
# Ces tests démarrent réellement un serveur sur un port de test
describe "Integration tests" do
  it "responds to actual HTTP requests" do
    with_http_server do |_|
      response = HTTP::Client.get("http://localhost:8080/")
      response.status_code.should eq(200)
      response.headers["Content-Type"].should eq("application/json")

      response_body = JSON.parse(response.body)
      response_body["status"].as_s.should eq("ok")
    end
  end
end
