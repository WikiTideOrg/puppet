# frozen_string_literal: true

require 'spec_helper'

describe 'dirname' do
  it { is_expected.not_to be_nil }
  it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{No arguments given}) }
  it { is_expected.to run.with_params('one', 'two').and_raise_error(Puppet::ParseError, %r{Too many arguments given}) }
  it { is_expected.to run.with_params([]).and_raise_error(Puppet::ParseError, %r{Requires string as argument}) }
  it { is_expected.to run.with_params({}).and_raise_error(Puppet::ParseError, %r{Requires string as argument}) }
  it { is_expected.to run.with_params(1).and_raise_error(Puppet::ParseError, %r{Requires string as argument}) }
  it { is_expected.to run.with_params('').and_raise_error(Puppet::ParseError, %r{Requires a non-empty string as argument}) }
  it { is_expected.to run.with_params(:undef).and_raise_error(Puppet::ParseError, %r{string as argument}) }
  it { is_expected.to run.with_params(nil).and_raise_error(Puppet::ParseError, %r{string as argument}) }
  it { is_expected.to run.with_params('/path/to/a/file.ext').and_return('/path/to/a') }
  it { is_expected.to run.with_params('relative_path/to/a/file.ext').and_return('relative_path/to/a') }

  context 'with UTF8 and double byte characters' do
    it { is_expected.to run.with_params('scheme:///√ạĺűē/竹.ext').and_return('scheme:///√ạĺűē') }
    it { is_expected.to run.with_params('ҝẽγ:/√ạĺűē/竹.ㄘ').and_return('ҝẽγ:/√ạĺűē') }
  end
end
