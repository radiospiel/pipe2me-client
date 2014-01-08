require "shellwords"

module Pipe2me::Sys
  extend self

  class ExitError < RuntimeError; end

  def sys(*args)
    cmd, stdout = _sys(*args)
    return stdout if $?.exitstatus == 0
  end

  def sys!(*args)
    cmd, stdout = _sys(*args)
    return stdout if $?.exitstatus == 0
    raise ExitError, "#{cmd} failed with exit code #{$?.exitstatus}"
  end

  def sh(*args)
    sys "sh", "-c", *args
  end

  def sh!(*args)
    sys! "sh", "-c", *args
  end

  private

  def _sys(*args)
    cmd = args.
      map { |arg| Shellwords.escape arg.to_s }.
      join(" ")

    stdout = IO.popen(cmd, &:read)
    [ cmd, stdout ]
  end
end
