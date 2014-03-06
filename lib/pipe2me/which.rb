module Which
  def self.which!(cmd)
    path = `which #{cmd}`.chomp
    raise "Cannot find #{cmd} in your $PATH. Is it installed?" if path == ""
    path
  end

  DAEMON = which!(:daemon)
  AUTOSSH = which!(:autossh)
  MONIT = which!(:monit)
end
