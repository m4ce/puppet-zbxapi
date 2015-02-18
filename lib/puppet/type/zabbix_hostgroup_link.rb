Puppet::newtype(:zabbix_hostgroup_link) do
  desc "Link a hostgroup to a Zabbix host"

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name) do
    desc "Hostgroup link name"
    isnamevar
  end

  newparam(:host) do
    desc "The host that should get linked to the hostgroup"
    isrequired
    isnamevar
  end

  newparam(:hostgroup) do
    desc "The hostgroup name"
    isrequired
    isnamevar
  end

  # Our title_patterns method for mapping titles to namevars for supporting
  # composite namevars.
  def self.title_patterns
    identity = lambda {|x| x}
    [
      [
        /^((.*?):(.*?))$/,
        [
          [ :name, identity ],
          [ :host, identity ],
          [ :hostgroup, identity ]
        ]
      ],
    ]
  end

  autorequire(:zabbix_host) { :host }
end
