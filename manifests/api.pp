define uchiwa::api(
  $host,
  $ssl     = false,
  $port    = 4567,
  $user    = 'sensu',
  $pass    = 'sensu',
  $path    = '',
  $timeout = 5000
  ) {

  validate_re($name, '^[a-zA-Z0-9_ ]*$')
  validate_re($host, '^[a-zA-Z0-9_.]*$')
  validate_bool($ssl)
  validate_re($port, '^[0-9]*$')
  validate_re($user, '^[a-zA-Z0-9_]*$')
  validate_re($path, '^[a-zA-Z0-9_/]*$')
  validate_re($timeout, '^[0-9]*$')

  concat::fragment { "50-uchiwa-api-${name}":
    target  => '/etc/sensu/uchiwa.json',
    order   => '50',
    content => template('uchiwa/etc/sensu/uchiwa_api.json.erb'),
  }

#  datacat_fragment { "uchiwa-api-${name}":
#    target => '/etc/sensu/uchiwa.json',
#    data   => {
#      bunny => '{
#      "name": "$title",
#      "host": "$host",
#      "port": $port,
#      "ssl": $ssl,
#      "user": "$user",
#      "pass": "$pass",
#      "path": "$path",
#      "timeout": $timeout
#    }'
#    },
#  }

}