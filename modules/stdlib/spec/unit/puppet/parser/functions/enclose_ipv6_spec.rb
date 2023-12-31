# frozen_string_literal: true

require 'spec_helper'

describe 'enclose_ipv6' do
  let(:node) { Puppet::Node.new('localhost') }
  let(:compiler) { Puppet::Parser::Compiler.new(node) }
  let(:scope) { Puppet::Parser::Scope.new(compiler) }

  it 'exists' do
    expect(Puppet::Parser::Functions.function('enclose_ipv6')).to eq('function_enclose_ipv6')
  end

  it 'raises a ParseError if there is less than 1 arguments' do
    expect { scope.function_enclose_ipv6([]) }.to(raise_error(Puppet::ParseError))
  end

  it 'raises a ParseError if there is more than 1 arguments' do
    expect { scope.function_enclose_ipv6(['argument1', 'argument2']) }.to(raise_error(Puppet::ParseError))
  end

  it 'raises a ParseError when given garbage' do
    expect { scope.function_enclose_ipv6(['garbage']) }.to(raise_error(Puppet::ParseError))
  end

  it 'raises a ParseError when given something else than a string or an array' do
    expect { scope.function_enclose_ipv6([['1' => '127.0.0.1']]) }.to(raise_error(Puppet::ParseError))
  end

  it 'does not raise a ParseError when given a single ip string' do
    expect { scope.function_enclose_ipv6(['127.0.0.1']) }.not_to raise_error
  end

  it 'does not raise a ParseError when given * as ip strint g' do
    expect { scope.function_enclose_ipv6(['*']) }.not_to raise_error
  end

  it 'does not raise a ParseError when given an array of ip strings' do
    expect { scope.function_enclose_ipv6([['127.0.0.1', 'fe80::1']]) }.not_to raise_error
  end

  it 'does not raise a ParseError when given differently notations of ip addresses' do
    expect { scope.function_enclose_ipv6([['127.0.0.1', 'fe80::1', '[fe80::1]']]) }.not_to raise_error
  end

  it 'raises a ParseError when given a wrong ipv4 address' do
    expect { scope.function_enclose_ipv6(['127..0.0.1']) }.to(raise_error(Puppet::ParseError))
  end

  it 'raises a ParseError when given a ipv4 address with square brackets' do
    expect { scope.function_enclose_ipv6(['[127.0.0.1]']) }.to(raise_error(Puppet::ParseError))
  end

  it 'raises a ParseError when given a wrong ipv6 address' do
    expect { scope.function_enclose_ipv6(['fe80:::1']) }.to(raise_error(Puppet::ParseError))
  end

  it 'embraces ipv6 adresses within an array of ip addresses' do
    result = scope.function_enclose_ipv6([['127.0.0.1', 'fe80::1', '[fe80::2]']])
    expect(result).to(eq(['127.0.0.1', '[fe80::1]', '[fe80::2]']))
  end

  it 'embraces a single ipv6 adresse' do
    result = scope.function_enclose_ipv6(['fe80::1'])
    expect(result).to(eq(['[fe80::1]']))
  end

  it 'does not embrace a single ipv4 adresse' do
    result = scope.function_enclose_ipv6(['127.0.0.1'])
    expect(result).to(eq(['127.0.0.1']))
  end
end
