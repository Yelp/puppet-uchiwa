# == Class uchiwa::config
#
# This class is called from uchiwa
#
class uchiwa::config {

  concat { '/etc/sensu/uchiwa.json':
    owner   => 'root',
    group   => 'root',
    mode    => '0655',
  }

  concat::fragment { '01-uchiwa-header':
    target  => '/etc/sensu/uchiwa.json',
    order   => '01',
    content => template('uchiwa/etc/sensu/uchiwa_header.json.erb'),
  }

  concat::fragment { '99-uchiwa-footer':
    target  => '/etc/sensu/uchiwa.json',
    order   => '99',
    content => template('uchiwa/etc/sensu/uchiwa_footer.json.erb'),
  }

  #->
  #exec { 'empty_hash':
  #  command => '/bin/sed -i -e"/\s*{\s*}\,/d" /etc/sensu/uchiwa.json',
  #  require => Concat['/etc/sensu/uchiwa.json'],
  #}

  #datacat { '/etc/sensu/uchiwa.json':
  #  template => 'uchiwa/etc/sensu/uchiwa.json.erb',
  #}
}