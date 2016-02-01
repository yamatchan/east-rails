require 'ipaddr'

class VmManager
  IP_ADDR = "169.254.16.0"

  def initialize(terminal_ip, cid, ip, os, ram)
    self.class.create(terminal_ip, cid, ip, os, ram, 1, "root")
  end

  def self.create(terminal_ip, cid, ip, os, ram, num, pass)
    for i in (0...(num))
      cmd = []
      cmd.concat(["sudo vzctl create #{cid} --ostemplate #{os} --config #{ram}"])
      cmd.concat(self.add_ethif(cid, 0))
      cmd.concat(self.add_ethif(cid, 1))
      cmd.concat(self.start(cid))
      cmd.concat(self.add_if(cid, 0))
      cmd.concat(self.add_if(cid, 1))
      cmd.push("sudo vzctl exec #{cid} \\\"echo \\\"auto eth0\\\" >> /etc/network/interfaces\\\"")
      cmd.push("sudo vzctl exec #{cid} \\\"echo \\\"iface eth0 inet dhcp\\\" >> /etc/network/interfaces\\\"")
      cmd.push("sudo vzctl exec #{cid} \\\"echo \\\"auto eth1\\\" >> /etc/network/interfaces\\\"")
      cmd.push("sudo vzctl exec #{cid} \\\"echo \\\"iface eth1 inet static\\\" >> /etc/network/interfaces\\\"")
      cmd.push("sudo vzctl exec #{cid} \\\"echo \\\"address #{ip}\\\" >> /etc/network/interfaces\\\"")
      cmd.push("sudo vzctl exec #{cid} \\\"echo \\\"netmask 255.255.0.0\\\" >> /etc/network/interfaces\\\"")
#      cmd.concat(self.exec_network(cid, 0, IPAddr.new("0.0.0.0")))
#      cmd.concat(self.exec_network(cid, 1, IPAddr.new(terminal_ip).mask(20) | cid))
      cmd.concat(self.set_user_password(cid, "root", pass))
      cmd_str = cmd.join(";")
      `ssh root@#{terminal_ip} "#{cmd_str}"`
    end
  end

  def self.start(ccid)
    ["sudo vzctl start #{ccid}"]
  end

  def self.add_ethif(ccid, port)
    ["sudo vzctl set #{ccid} --netif_add eth#{port} --save"]
  end

  def self.add_if(ccid, port)
    [
      "sudo brctl delif br-eth#{port} veth#{ccid}.#{port}",
      "sudo brctl addif br-eth#{port} veth#{ccid}.#{port}",
    ]
  end

  def self.exec_network(ccid, port, ip)
    if ip == "0.0.0.0" then
      ["sudo vzctl exec #{ccid} dhclient eth#{port}"]
    else
      ["sudo vzctl exec #{ccid} ifconfig eth#{port} #{ip}"]
    end
  end

  def self.set_user_password(ccid, user, pass)
    ["sudo vzctl set #{ccid} --userpasswd #{user}:#{pass}"]
  end

  def self.stop(ccid)
    output = `sudo vzctl stop #{ccid}`
    p output
  end

  def self.destroy(ccid)
    self.stop(ccid)
    output = `sudo vzctl destroy #{ccid}`
    p output
  end

  def self.restart(ccid)
    `sudo vzctl restart #{ccid}`
    self.add_if(0, ccid)
    self.add_if(1, ccid)
#    self.exec_network(ccid, 0, "dhcp")
#    self.exec_network(ccid, 1, IPAddr.new(IP_ADDR) | ccid)
#    self.exec_network(ccid,1,"dhcp")
  end

  def self.enter(ccid)
   `sudo vzctl enter #{ccid}`
  end
end

=begin
if ARGV.size == 5 then
  terminal_ip = ARGV[0].to_s
  cid = ARGV[1].to_i
  ip  = ARGV[2].to_s
  os  = ARGV[3].to_s
  ram = ARGV[4].to_s
  os = "debian-7.0-x86"
  ram = "vswap-256m"
  VMManager.new(terminal_ip, cid, ip, os, ram)
#  VMManager.restart(ccid)
else
  p "input arg"
end
=end
