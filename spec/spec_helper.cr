require "spec"
require "../src/cannaille"

def with_http_server(&)
  canaille = Canaille::Server.new
  begin
    spawn(name: "Canaille server") { canaille.listen }
    Fiber.yield
    yield canaille
  ensure
    canaille.close
  end
end
