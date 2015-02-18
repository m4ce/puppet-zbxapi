Puppet::Type.newtype(:zabbix_template_link) do
  desc "Link a template to a Zabbix host"

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name) do
    desc "Template link name"
    isnamevar
  end

  newparam(:host) do
    desc "Host that should be linked to the template"
    isrequired
    isnamevar
  end

  newparam(:template) do
    desc "Template name"
    isrequired
    isnamevar
  end

  # Our title_patterns method for mapping titles to namevars for supporting
  # composite namevars.
  def self.title_patterns
    title = lambda {|x| x}
    [
      [
        /^((.*?):(.*?))$/,
        [
          [ :name, title ],
          [ :host, title ],
          [ :template, title ]
        ]
      ]
    ]
  end

  autorequire(:zabbix_host) { :host }
end
