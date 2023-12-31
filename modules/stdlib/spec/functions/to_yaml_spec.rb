# frozen_string_literal: true

require 'spec_helper'

describe 'stdlib::to_yaml' do
  it { is_expected.not_to be_nil }
  it { is_expected.to run.with_params('').and_return("--- ''\n") }
  it { is_expected.to run.with_params(true).and_return(%r{--- true\n}) }
  it { is_expected.to run.with_params('one').and_return(%r{--- one\n}) }
  it { is_expected.to run.with_params([]).and_return("--- []\n") }
  it { is_expected.to run.with_params(['one']).and_return("---\n- one\n") }
  it { is_expected.to run.with_params(['one', 'two']).and_return("---\n- one\n- two\n") }
  it { is_expected.to run.with_params({}).and_return("--- {}\n") }
  it { is_expected.to run.with_params('key' => 'value').and_return("---\nkey: value\n") }

  it {
    expect(subject).to run.with_params('one' => { 'oneA' => 'A', 'oneB' => { 'oneB1' => '1', 'oneB2' => '2' } }, 'two' => ['twoA', 'twoB'])
                          .and_return("---\none:\n  oneA: A\n  oneB:\n    oneB1: '1'\n    oneB2: '2'\ntwo:\n- twoA\n- twoB\n")
  }

  it { is_expected.to run.with_params('‰').and_return("--- \"‰\"\n") }
  it { is_expected.to run.with_params('∇').and_return("--- \"∇\"\n") }

  it { is_expected.to run.with_params({ 'foo' => { 'bar' => true, 'baz' => false } }, 'indentation' => 4).and_return("---\nfoo:\n    bar: true\n    baz: false\n") }
end
