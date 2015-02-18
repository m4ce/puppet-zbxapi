require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "ruby", "zbxapi.rb"))

Puppet::Type.type(:zabbix_host).provide(:zbxapi) do
  desc "Zabbix host type"
  confine :feature => :zbxapi

  def self.instances
    extend ZbxAPI

    hosts = zbxapi.host.get({"output" => ["name", "host", "hostid", "status", "proxy_hostid"]})
    hosts.collect do |host|
      new(
        :name => host["name"],
        :host => host["host"],
        :hostid => host["hostid"],
        :status => host["status"],
        :proxy_hostid => host["proxy_hostid"],
        :ensure => :present
      )
    end
  end

  def self.prefetch(resources)
    extend ZbxAPI

    hosts = instances
    resources.keys.each do |name|
      if provider = hosts.find { |host| host.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    extend ZbxAPI

    raise Puppet::Error, "Could not create Zabbix host #{self.name}: No groups for host" if resource[:hostgroups].nil? or resource[:hostgroups].empty?

    hostgroups = []
    groups = resource[:hostgroups]
    groups = [groups] unless groups.is_a?(Array)

    groups.each do |group|
      hostgroup_id = zbxapi.hostgroup.get({"output" => ["groupid"], "filter" => {"name" => group}})
      hostgroups << hostgroup_id.first
    end

    zbxapi.host.create({
      "host" => resource[:name],
      "interfaces" => [
        {
          "type" => 1,
          "main" => 1,
          "useip" => resource[:ip] == nil ? 0 : 1,
          "usedns" => resource[:ip] == nil ? 1 : 0,
          "dns" => resource[:host],
          "ip" => resource[:ip] == nil ? "" : resource[:ip],
          "port" => 10050
        }
      ],
      "status" => resource[:enable] ? 0 : 1,
      "proxy_hostid" => resource[:proxy] == nil ? 0 : zbxapi.proxy.get({"output" => "proxyid", "filter" => {"host" => resource[:proxy]}})[0]["proxyid"],
      "groups" => hostgroups
    })

    @property_hash[:ensure] = :present
  end

  def destroy
    extend ZbxAPI

    zbxapi.host.delete("hostid" => @property_hash[:hostid])
    @property_hash.clear
  end

  # Using mk_resource_methods relieves us from having to explicitly write the getters for all properties
  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def enable
    @property_hash[:status] == "0" ? :true : :false
  end

  def enable=(value)
    @property_flush["status"] = (value == :true) ? "0" : "1"
  end

  def proxy
    extend ZbxAPI

    proxy_hash = zbxapi.proxy.get({"output" => ["host", "proxyid"]}).select { |hash| hash["proxyid"] == @property_hash[:proxy_hostid] }.first

    unless proxy_hash.nil?
      return proxy_hash["host"]
    else
      return nil
    end
  end

  def proxy=(value)
    extend ZbxAPI

    proxy_hash = zbxapi.proxy.get({"output" => ["proxyid"], "filter" => {"host" => value}}).first
    @property_flush["proxy_hostid"] = proxy_hash["proxyid"]
  end

  def flush
    extend ZbxAPI

    unless @property_flush.empty?
      @property_flush["hostid"] = @property_hash[:hostid]
      zbxapi.host.update(@property_flush)
    end
    @property_hash = resource.to_hash
  end
end
