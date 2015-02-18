require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "ruby", "zbxapi.rb"))

Puppet::Type.type(:zabbix_hostgroup_link).provide(:zbxapi) do
  desc "Zabbix hostgroup link type"
  confine :feature => :zbxapi

  def self.instances
    extend ZbxAPI

    hostgroups = zbxapi.hostgroup.get({"output" => ["name", "groupid"], "selectHosts" => ["name", "hostid"]})
    hostgroups.collect do |hostgroup|
      new(
        :name => hostgroup["name"],
        :groupid => hostgroup["groupid"],
        :hosts => hostgroup["hosts"]
      )
    end
  end

  def self.prefetch(resources)
    extend ZbxAPI

    hostgroups = instances
    resources.each do |name, resource|
      if provider = hostgroups.find { |hostgroup| hostgroup.name.downcase == resource[:hostgroup].downcase }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:hosts].each do |host|
      return true if host["name"] == resource[:host]
    end

    return false
  end

  def create
    extend ZbxAPI

    host = zbxapi.host.get({"output" => ["hostid"], "filter" => {"name" => resource[:host]}}).first
    raise Puppet::Error, "Could not link host '#{resource[:host]}' to hostgroup '#{resource[:hostgroup]}': no such host" if host.nil?

    zbxapi.hostgroup.massadd({"groups" => [{"groupid" => @property_hash[:groupid]}], "hosts" => [{"hostid" => host["hostid"]}]})

    @property_hash[:hosts] << {"name" => resource[:host], "hostid" => host["hostid"]}
  end

  def destroy
    extend ZbxAPI

    host = zbxapi.host.get({"output" => ["hostid"], "filter" => {"name" => resource[:host]}}).first
    raise Puppet::Error, "Could not unlink host '#{resource[:host]}' to hostgroup '#{resource[:hostgroup]}': no such host" if host.nil?

    zbxapi.hostgroup.massremove({"groupids" => [@property_hash[:groupid]], "hostids" => [host["hostid"]]})

    @property_hash[:hosts].delete({"name" => resource[:host], "hostid" => host["hostid"]})
  end
end
