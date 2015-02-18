class zbxapi ($url, $user, $password) {
  file {"${::settings::confdir}/zbxapi.yaml":
    owner => "root",
    group => "root",
    mode => "0600",
    content => template("zbxapi/zbxapi.yaml.erb")
  }
}
