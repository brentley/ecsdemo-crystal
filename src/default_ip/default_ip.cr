require "interface_address"

class DefaultIf
  @@default_if : String = "NONE"
  @@default_ip : String = "NONE"

  def self.getif
    interface = IO::Memory.new
    command = "awk '$2 == 00000000 { print $1 }' /proc/net/route"
    getroute = Process.run(command, shell: true, output: interface)
    if !getroute.success? || !getroute.normal_exit? || getroute.signal_exit?
      command = "route -n get default | awk '/interface/ {print $2}'"
      getroute = Process.run(command, shell: true, output: interface)
    end
    interface = interface.to_s
    interface = interface.gsub "\n",""
    @@default_if = interface
  end

  def self.getip
    @@default_if = DefaultIf.getif
		InterfaceAddress.get_interface_addresses.each do |a|
  		iface_name = a.interface_name
  		iface_ip = a.ip_address.address
  		if @@default_if == iface_name
    		if iface_ip.includes? "."
      		@@default_ip = iface_ip
          return @@default_ip
    		end
  		end
		end
  end
end
