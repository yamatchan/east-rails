require 'ipaddr'

class VmManager
  IP_ADDR = "169.254.16.0"

  def initialize(terminal_ip, cid, ip, os, conf, host_name, cpuunits, ram, storage)
    self.class.create(terminal_ip, cid, ip, os, conf, 1, "root", host_name, cpuunits, ram.to_i, storage.to_i)
  end

  def self.create(terminal_ip, cid, ip, os, conf, num, pass, host_name, cpuunits, ram, storage)
    for i in (0...(num))
      cmd = []
      cmd.concat(["sudo vzctl create #{cid} --ostemplate #{os} --config #{conf}"])
      cmd.push("sudo vzctl set #{cid} --cpuunits #{cpuunits} --cpulimit 30 --save")
      cmd.push("sudo vzctl set #{cid} --vmguarpages #{ram*256} --privvmpages #{ram*256*2} --save")
      cmd.push("sudo vzctl set #{cid} --diskspace #{storage}G:#{storage+0.2}G --save")
      cmd.push("sudo vzctl set #{cid} --hostname #{host_name} --save")
      cmd.concat(self.add_ethif(cid, 0))
      cmd.concat(self.add_ethif(cid, 1))
      cmd.concat(self.start_cmd(cid))
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

  def self.start_cmd(ccid)
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

  def self.livemigrate(src_ip, dst_ip, cid)
    `ssh root@#{src_ip} "vzmigrate --online #{dst_ip} #{cid}"`
  end

  def self.migrate(src_ip, dst_ip, cid)
    `ssh root@#{src_ip} "vzmigrate #{dst_ip} #{cid}"`
  end

  def self.start(ip, cid)
    `ssh root@#{ip} "vzctl start #{cid}"`
  end

  def self.stop(ip, cid)
    `ssh root@#{ip} "vzctl stop #{cid}"`
  end

  def self.destroy(ip, cid)
    `ssh root@#{ip} "vzctl destroy #{cid}"`
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
