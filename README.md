# Puppet Zabbix API type and providers

A collection of Puppet type and providers to automate Zabbix tasks by leveraging its API.

The type and providers are <b>fully idempotent</b>.

## Installation
Please note that the zbxapi ruby gem (https://rubygems.org/gems/zbxapi) is required on the system where the exported resources will be realized.

## Usage
You would typically use exported resources and then realize them on the Zabbix node using spaceship operators.

Adding a host is as simple as:
```
@@zabbix_host {$::fqdn:
  ip => $::ipaddress,
  proxy => "proxy.example.org",
  hostgroups => ["Puppet discovered machines"],
  enable => true
}
```

You could then add the host to specific groups based on specific facts anywhere in your manifests:
```
@@zabbix_hostgroup_link {["${::fqdn}:${::location}", "${::fqdn}:${::environment}"]: }
```

And obviously link the host to the right template(s) in a similar way:
```
@@zabbix_template_link {"${::fqdn}:Template-${::osfamily}": }
```

And then realize everything on the Zabbix node using resource collectors (aka spaceship operators):
```
Zabbix_host <<| |>> -> Zabbix_hostgroup_link <<| |>> -> Zabbix_template_link <<| |>>
```

## Contact
Matteo Cerutti - matteo.cerutti@hotmail.co.uk
