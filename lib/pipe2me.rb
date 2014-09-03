module Pipe2me
  def self.server;          @server; end
  def self.server=(server); @server = server; end
end

require "simple/ui"

require_relative "pipe2me/version"
require_relative "pipe2me/tunnel"

