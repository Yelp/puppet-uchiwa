# = Class: uchiwa::repo::yum
#
# Adds the uchiwa YUM repo support
#
class uchiwa::repo::yum {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $uchiwa::install_repo  {
    if $uchiwa::repo_source {
      $url = $uchiwa::repo_source
    } else {
      $url = $uchiwa::repo ? {
        'unstable'  => "https://repositories.sensuapp.org/yum-unstable/${::operatingsystemmajrelease}/\$basearch/",
        default     => "https://repositories.sensuapp.org/yum/${::operatingsystemmajrelease}/\$basearch/"
      }
    }

    yumrepo { 'uchiwa':
      enabled  => 1,
      baseurl  => $url,
      gpgcheck => 0,
      name     => 'uchiwa',
      descr    => 'sensuapp.org uchiwa repo',
      before   => Package['uchiwa'],
    }
  }

}
