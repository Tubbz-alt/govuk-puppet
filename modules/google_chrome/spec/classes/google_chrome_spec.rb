require_relative '../../../../spec_helper'

describe 'google_chrome', :type => :class do
  it { is_expected.to compile }

  it { is_expected.to compile.with_all_deps }

  it { is_expected.to contain_class('google_chrome') }
end
