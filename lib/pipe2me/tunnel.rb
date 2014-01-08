require "pipe2me/ext/http"
require "pipe2me/ext/shell_format"

module Pipe2me::Tunnel
  HTTP = Pipe2me::HTTP
  ShellFormat = Pipe2me::ShellFormat

  extend self

  def setup(options)
    if File.exists?("pipe2me.info.inc")
      raise "Found existing pipe2me configuration in #{Dir.getwd}"
    end

    # [todo] escape auth option
    response = HTTP.post! "#{Pipe2me::Config.server}/subdomains/#{options[:auth]}",
      "protocols" => options[:protocols]

    server_info = ShellFormat.parse(response)

    raise(ArgumentError, "Missing :fqdn information") unless server_info[:fqdn]

    ShellFormat.write "pipe2me.info.inc", server_info
    ShellFormat.write "pipe2me.local.inc",
                        :server => Pipe2me::Config.server,
                        :local_ports => options[:local_ports]

    server_info
  end
end
