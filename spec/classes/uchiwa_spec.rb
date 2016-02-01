require 'spec_helper'

describe 'uchiwa' do
  let(:facts) {
    {
      :osfamily => 'RedHat',
      :concat_basedir => '/dne',
     }
  }

  it 'should compile' do should create_class('uchiwa') end
  it { should contain_class('uchiwa::config')}

  context 'config file' do
    it { should contain_file('/etc/sensu/uchiwa.json').with_ensure('file') }
    it { should contain_file('/etc/sensu/uchiwa.json').with_content(/"host": "127.0.0.1"/) }
    it { should contain_file('/etc/sensu/uchiwa.json').with_owner('uchiwa') }
    it { should contain_file('/etc/sensu/uchiwa.json').with_group('uchiwa') }
    it { should contain_file('/etc/sensu/uchiwa.json').with_mode('0440') }
  end

  context 'package' do
    context 'defaults' do
      it { should create_class('uchiwa::repo::yum') }
      it { should contain_package('uchiwa').with_ensure('latest') }
      it { should contain_file('/etc/sensu/uchiwa.json') }
    end

    context 'setting version' do
      let(:params) { {
        :version      => '0.1.5',
      } }

      it { should contain_package('uchiwa').with(
        :ensure => '0.1.5'
      ).that_notifies('Service[uchiwa]') }
    end

    context 'repos' do

      context 'ubuntu' do
        let(:facts) {
          {
            :osfamily => 'Debian',
            :lsbdistcodename => 'jessie',
            :fqdn => 'testhost.domain.com',
            :concat_basedir => '/dne'
          }
        }

        context 'with puppet-apt installed' do
          let(:pre_condition) { [ 'define apt::source ($ensure, $location, $release, $repos, $include, $key) {}' ] }

          context 'default' do
            it { should contain_apt__source('uchiwa').with(
              :ensure   => 'present',
              :location => 'https://repositories.sensuapp.org/apt',
              :release  => 'jessie',
              :repos    => 'main',
              :include  => { 'src' => false, 'deb' => true },
              :key      => { 'id' => 'EE15CFF6AB6E4E290FDAB681A20F259AEB9C94BB', 'source' => 'https://repositories.sensuapp.org/apt/pubkey.gpg' },
              :before   => 'Package[uchiwa]'
            ) }
          end

          context 'unstable repo' do
            let(:params) {
              {
                :repo => 'unstable',
                :repo_release => 'stretch',
              }
            }
            it { should contain_apt__source('uchiwa').with(
              :repos => 'unstable',
              :release  => 'stretch'
            )}
          end

          context 'override repo url' do
            let(:params) { { :repo_source => 'http://repo.mydomain.com/apt' } }
            it { should contain_apt__source('uchiwa').with( :location => 'http://repo.mydomain.com/apt') }

            it { should_not contain_apt__key('uchiwa').with(
              :key         => '7580C77F',
              :key_source  => 'http://repo.mydomain.com/apt/pubkey.gpg'
            ) }
          end

          context 'override key ID and key source' do
            let(:params) { { :repo_key_id => 'FFFFFFFF', :repo_key_source => 'http://repo.mydomina.com/apt/pubkey.gpg' } }

            it { should_not contain_apt__key('uchiwa').with(
              :key         => 'FFFFFFFF',
              :key_source  => 'http://repo.mydomain.com/apt/pubkey.gpg'
            ) }
          end

          context 'install_repo => false' do
            let(:params) { { :install_repo => false, :repo => 'main' } }

            it { should_not contain_apt__source('uchiwa') }

            it { should_not contain_apt__key('uchiwa').with(
              :key         => '7580C77F',
              :key_source  => 'https://repositories.sensuapp.org/apt/pubkey.gpg'
            ) }

            it { should contain_package('uchiwa').with(
              :require => nil
            ) }
          end
        end

        context 'without puppet-apt installed' do
          it { expect { should raise_error(Puppet::Error) } }
        end
      end

      context 'redhat' do
        let(:facts) { { :osfamily => 'RedHat', :operatingsystemmajrelease => '6',:concat_basedir => '/dne', } }

        context 'default' do
          it { should contain_yumrepo('uchiwa').with(
            :enabled   => 1,
            :baseurl   => 'https://repositories.sensuapp.org/yum/6/$basearch/',
            :gpgcheck  => 0,
            :before    => 'Package[uchiwa]'
          ) }
        end

        context 'unstable repo' do
          let(:params) { { :repo => 'unstable' } }
          it { should contain_yumrepo('uchiwa').with(:baseurl => 'https://repositories.sensuapp.org/yum-unstable/6/$basearch/' )}
        end

        context 'override repo url' do
          let(:params) { { :repo_source => 'http://repo.mydomain.com/yum' } }
          it { should contain_yumrepo('uchiwa').with( :baseurl => 'http://repo.mydomain.com/yum') }
        end

        context 'install_repo => false' do
          let(:params) { { :install_repo => false } }

          it { should_not contain_yumrepo('uchiwa') }

          it { should contain_package('uchiwa').with(
            :require => nil
          ) }
        end
      end
    end

  end

  context 'with sensu_api_endpoints' do
    let(:params) {{ :sensu_api_endpoints => [ { 'name' => 'foo', 'host' => 'bar' } ] }}
    it {
      should contain_file('/etc/sensu/uchiwa.json') \
        .with_content(/"name": "foo"/) \
        .with_content(/"host": "bar"/)
    }
  end

  context 'with sensu_api_endpoints multiple hosts' do
    let(:params) {{ :sensu_api_endpoints => [ { 'name' => 'foo', 'host' => ['bar', 'baz' ] } ] }}
    it {
      should contain_file('/etc/sensu/uchiwa.json') \
        .with_content(/"name": "foo"/) \
        .with_content(/"host": "bar"/)
        .with_content(/"host": "baz"/)
    }
  end

  context 'with multiple users' do
    let(:params) {{ :users => [ { 'username' => 'user1', 'password' => 'pass1', 'readonly' => true } ] }}
    it {
      should contain_file('/etc/sensu/uchiwa.json') \
        .with_content(/"username": "user1",\n        "password": "pass1",\n        "role": {\n          "readonly": true\n        }\n      }/)
    }
  end

  context 'with static JWT RSA keys' do
    let(:params) {{ :auth => { 'publickey' => '/etc/sensu/uchiwa.rsa.pub', 'privatekey' => '/etc/sensu/uchiwa.rsa' } }}
    it {
      should contain_file('/etc/sensu/uchiwa.json') \
      .with_content(/"auth": {\n      "publickey": "\/etc\/sensu\/uchiwa.rsa.pub",\n      "privatekey": "\/etc\/sensu\/uchiwa.rsa"\n    }/)
    }
  end

  context 'with usersoptions' do
    let(:params) {{ :usersoptions => { 'disableNoExpiration' => true, 'defaultTheme' => 'uchiwa-default' } }}
    it {
      should contain_file('/etc/sensu/uchiwa.json') \
        .with_content(/"disableNoExpiration": true/) \
        .with_content(/"defaultTheme": "uchiwa-default"/)
    }
  end

  context 'with debug log level' do
    let(:params) {{ :log_level => 'debug' }}
    it {
      should contain_file('/etc/sensu/uchiwa.json') \
        .with_content(/"loglevel": "debug"/)
    }
  end

end
