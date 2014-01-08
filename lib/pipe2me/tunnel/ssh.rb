module Pipe2me::Tunnel::SSH
  HTTP = Pipe2me::HTTP

  SSH_PUBKEY  = Pipe2me::Tunnel::SSH_PUBKEY
  SSH_PRIVKEY = Pipe2me::Tunnel::SSH_PRIVKEY

  def ssh_keygen
    sh! "ssh-keygen -t rsa -N '' -C #{config.fqdn} -f pipe2me.id_rsa >&2"
    sh! "chmod 600 pipe2me.id_rsa*"
    HTTP.post!("#{url}/id_rsa.pub", File.read(SSH_PUBKEY), {'Content-Type' =>'text/plain'})
  rescue
    FileUtils.rm_rf SSH_PRIVKEY
    FileUtils.rm_rf SSH_PUBKEY
    raise
  end
end
