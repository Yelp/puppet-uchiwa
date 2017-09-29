# = Class: uchiwa::repo::apt
#
# Adds the uchiwa repo to Apt
#
class uchiwa::repo::apt {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $uchiwa::install_repo {
    if defined(apt::source)  {

      $ensure = $uchiwa::install_repo ? {
        true    => 'present',
        default => 'absent'
      }

      if $uchiwa::repo_source {
        $url = $uchiwa::repo_source
      } else {
        $url = 'https://repositories.sensuapp.org/apt'
      }

      # ignoring the puppet-lint plugin because of a bug that warns on the next
      # line.
      if $::uchiwa::repo_release == undef { #lint:ignore:undef_in_function
        $release = $::lsbdistcodename
      } else {
        $release = $::uchiwa::repo_release
      }

      apt::source { 'uchiwa':
        ensure   => $ensure,
        before   => Package['uchiwa'],
        include  => {
          'src' => false,
          'deb' => true,
        },
        key      => {
          'id'     => $uchiwa::repo_key_id,
          'source' => $uchiwa::repo_key_source,
        },
        location => $url,
        release  => $release,
        repos    => $uchiwa::repo,
      }

    } else {
      fail('This class requires puppet-apt module')
    }
  }
}
