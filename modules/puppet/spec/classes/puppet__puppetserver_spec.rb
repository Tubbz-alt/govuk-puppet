require_relative '../../../../spec_helper'

describe 'puppet::puppetserver', :type => :class do
  # concat_basedir needed for puppetdb module (for postgresql)
  let(:facts) {{
    :concat_basedir => '/var/lib/puppet/concat/',
    :id             => 'root',
    :path           => 'concatted_file',
  }}

  it do
    is_expected.to contain_service('puppetserver').with_ensure('running')
  end

  it { is_expected.to contain_class('puppet::puppetdb') }
  it { is_expected.to contain_class('puppet::puppetserver::nginx') }

  it do
    is_expected.to contain_class('puppet')
    is_expected.to contain_class('puppet::puppetserver::config')
    is_expected.not_to contain_class('puppet::puppetserver::sentry')
  end

  context 'with sentry_dsn' do
    let(:params) do
      { :sentry_dsn => 'rspec' }
    end

    it do
      is_expected.to contain_class('puppet::puppetserver::sentry')
    end
  end
end
