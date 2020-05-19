require "logger"
require "http/server"

log = Logger.new(STDOUT)
log.level = Logger::DEBUG

log.debug("Created logger")
log.info("Program started")
log.warn("Nothing to do!")

code_hash = File.read("code_hash.txt")
ip = ENV["IP"]
az = ENV["AZ"]
log.debug("code_hash is: #{code_hash}")
log.debug("ip is: #{ip}")
log.debug("az is: #{az}")

az_message = ENV["AZ"]

server = HTTP::Server.new(
  [
    HTTP::ErrorHandler.new,
    HTTP::LogHandler.new,
    HTTP::CompressHandler.new,
    ]) do |context|
      if context.request.path == "/crystal" || context.request.path == "/crystal/"
        context.response.content_type = "text/plain"
        context.response.print "Crystal backend: Hello! from #{az_message} commit #{code_hash}"
      elsif context.request.path == "/crystal/api" || context.request.path == "/crystal/api/"
        context.response.content_type = "application/json"
        context.response.print %Q({"from":"Crystal backend", "message": "#{az_message}", "commit": "#{code_hash.chomp}"})
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
server.bind_tcp "0.0.0.0", 3000
server.listen
