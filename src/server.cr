require "logger"
require "http/server"
require "./default_ip"

log = Logger.new(STDOUT)
log.level = Logger::DEBUG

log.debug("Created logger")
log.info("Program started")
log.warn("Nothing to do!")

code_hash = File.read("code_hash.txt")
log.debug("code_hash is: #{code_hash}")

default_ip = DefaultIf.getip
log.debug("default_ip is: #{default_ip}")

if default_ip
  net_octet = default_ip.split(".")[2]
  log.debug("net_octet is: #{net_octet}")
end

case net_octet
  when "100"
  	az = "1a"
  when "101"
  	az = "1b"
  when "102"
  	az = "1c"
else
	az = "unknown"
end
log.debug("az is: #{az}")

server = HTTP::Server.new("0.0.0.0", 3000,
  [
    HTTP::ErrorHandler.new,
    HTTP::LogHandler.new,
    HTTP::CompressHandler.new,
    ]) do |context|
      if context.request.path == "/crystal" || context.request.path == "/crystal/"
        context.response.content_type = "text/plain"
        context.response.print "Crystal backend: Hello! from #{default_ip} in AZ-#{az} commit #{code_hash}"
      elsif context.request.path == "/health"
        context.response.content_type = "text/plain"
        context.response.print "Healthy!"
      else
        context.response.status_code = 404
        context.response.headers["Content-Type"] = "text/plain"
        context.response.puts "Not Found"
      end
    end

puts "Listening on http://0.0.0.0:3000"
server.listen
