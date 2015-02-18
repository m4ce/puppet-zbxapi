require "puppet"

module ZbxAPI
  def zbxapi
    return nil unless Puppet.features.zbxapi?

    require "zbxapi"

    config_file = ::File.join(Puppet.settings[:confdir], "zbxapi.yaml")
    raise(Puppet::ParseError, "Zabbix API config file '#{config_file}' not readable") unless File.exists?(config_file)
    config = ::YAML.load_file(config_file)

    api = ::ZabbixAPI.new(config["zabbix_url"], :verify_ssl => config["verify_ssl"] || false, :http_timeout => config["http_timeout"] || 300)
    api.login(config["zabbix_user"], config["zabbix_password"])

    return api
  end
end
