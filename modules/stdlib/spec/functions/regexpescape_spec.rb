# frozen_string_literal: true

require 'spec_helper'

describe 'regexpescape' do
  describe 'signature validation' do
    it { is_expected.not_to be_nil }
    it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }

    it {
      pending('Current implementation ignores parameters after the first.')
      expect(subject).to run.with_params('', '').and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i)
    }

    it { is_expected.to run.with_params(1).and_raise_error(Puppet::ParseError, %r{Requires either array or string to work}) }
    it { is_expected.to run.with_params({}).and_raise_error(Puppet::ParseError, %r{Requires either array or string to work}) }
    it { is_expected.to run.with_params(true).and_raise_error(Puppet::ParseError, %r{Requires either array or string to work}) }
  end

  describe 'handling normal strings' do
    it 'calls ruby\'s Regexp.escape function' do
      expect(Regexp).to receive(:escape).with('regexp_string').and_return('escaped_regexp_string').once
      expect(subject).to run.with_params('regexp_string').and_return('escaped_regexp_string')
    end
  end

  describe 'handling classes derived from String' do
    it 'calls ruby\'s Regexp.escape function' do
      regexp_string = AlsoString.new('regexp_string')
      expect(Regexp).to receive(:escape).with(regexp_string).and_return('escaped_regexp_string').once
      expect(subject).to run.with_params(regexp_string).and_return('escaped_regexp_string')
    end
  end

  describe 'strings in arrays handling' do
    it { is_expected.to run.with_params([]).and_return([]) }
    it { is_expected.to run.with_params(['one*', 'two']).and_return(['one\*', 'two']) }
    it { is_expected.to run.with_params(['one*', 1, true, {}, 'two']).and_return(['one\*', 1, true, {}, 'two']) }

    context 'with UTF8 and double byte characters' do
      it { is_expected.to run.with_params(['ŏŉε*']).and_return(['ŏŉε\*']) }
      it { is_expected.to run.with_params(['インターネット*']).and_return(['インターネット\*']) }
    end
  end
end
