Puppet::Type.newtype(:zabbix_host) do
  desc "Manage a Zabbix host"

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:host, :namevar => true) do
    desc "Host name"
  end

  newparam(:ip) do
    desc "Host ip address"
  end

  newparam(:hostgroups) do
    desc "Host groups the host should belong to"
  end

  newparam(:hostname) do
    desc "Visible name of the host"
  end

  newproperty(:proxy) do
    desc "Proxy used to monitor the host"
  end

  newproperty(:enable) do
    desc "Whether a host should be enabled or not"

    newvalue(:true)
    newvalue(:false)

    defaultto :true
  end
end
