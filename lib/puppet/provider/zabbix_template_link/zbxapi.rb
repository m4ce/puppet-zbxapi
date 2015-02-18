require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "ruby", "zbxapi.rb"))

Puppet::Type.type(:zabbix_template_link).provide(:zbxapi) do
  desc "Zabbix template link type"
  confine :feature => :zbxapi

  def self.instances
    extend ZbxAPI

    templates = zbxapi.template.get({"output" => ["name", "templateid"], "selectHosts" => ["name", "hostid"]})
    templates.collect do |template|
      new(
        :name => template["name"],
        :templateid => template["templateid"],
        :hosts => template["hosts"]
      )
    end
  end

  def self.prefetch(resources)
    extend ZbxAPI

    templates = instances
    resources.each do |name, resource|
      if provider = templates.find { |template| template.name.downcase == resource[:template].downcase }
        resources[name].provider = provider.clone
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
    raise Puppet::Error, "Could not link host '#{resource[:host]}' to template '#{resource[:template]}': no such host" if host.nil?

    zbxapi.template.massadd({"templates" => [{"templateid" => @property_hash[:templateid]}], "hosts" => [{"hostid" => host["hostid"]}]})

    @property_hash[:hosts] << {"name" => resource[:host], "hostid" => host["hostid"]}
  end

  def destroy
    extend ZbxAPI

    host = zbxapi.host.get({"output" => ["hostid"], "filter" => {"name" => resource[:host]}}).first
    raise Puppet::Error, "Could not unlink host '#{resource[:host]}' to template '#{resource[:template]}': no such host" if host.nil?

    zbxapi.template.massremove({"templateids" => [@property_hash[:templateid]], "hostids" => [host["hostid"]]})

    @property_hash[:hosts].delete({"name" => resource[:host], "hostid" => host["hostid"]})
  end
end
