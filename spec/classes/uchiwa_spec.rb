require 'spec_helper'

describe 'uchiwa', :type => :class do
  context 'on RedHat OS', :compile do
    let :facts do
      {
        :osfamily => 'RedHat',
      }
    end

    context 'with default params' do
      it do
        should contain_package('uchiwa')
      end
    end
  end

  context 'on Debian OS', :compile do
    let :facts do
      {
        :osfamily  => 'Debian',
        :lsbdistid => 'Debian',
      }
    end

    context 'with default params' do
      it do
        should contain_package('uchiwa')
      end
    end
  end

  context 'on unsupported OS' do
    let :facts do
      {
        :osfamily  => 'Unsupported',
      }
    end

    context 'with default params' do
      it do
        expect {
          should compile.with_all_deps
        }.to raise_error(Puppet::Error, /not supported/)
      end
    end
  end
end