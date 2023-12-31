# frozen_string_literal: true

require 'spec_helper'

describe 'parseyaml' do
  it 'exists' do
    expect(subject).not_to be_nil
  end

  it 'raises an error if called without any arguments' do
    expect(subject).to run.with_params
                          .and_raise_error(%r{wrong number of arguments}i)
  end

  context 'with correct YAML data' do
    it 'is able to parse a YAML data with a String' do
      actual_array = ['--- just a string', 'just a string']
      actual_array.each do |actual|
        expect(subject).to run.with_params(actual).and_return('just a string')
      end
    end

    it 'is able to parse YAML data with a Hash' do
      expect(subject).to run.with_params("---\na: '1'\nb: '2'\n")
                            .and_return('a' => '1', 'b' => '2')
    end

    it 'is able to parse YAML data with an Array' do
      expect(subject).to run.with_params("---\n- a\n- b\n- c\n")
                            .and_return(['a', 'b', 'c'])
    end

    it 'is able to parse YAML data with a mixed structure' do
      expect(subject).to run.with_params("---\na: '1'\nb: 2\nc:\n  d:\n  - :a\n  - true\n  - false\n")
                            .and_return('a' => '1', 'b' => 2, 'c' => { 'd' => [:a, true, false] })
    end

    it 'is able to parse YAML data with a UTF8 and double byte characters' do
      expect(subject).to run.with_params("---\na: ×\nこれ: 記号\nです:\n  ©:\n  - Á\n  - ß\n")
                            .and_return('a' => '×', 'これ' => '記号', 'です' => { '©' => ['Á', 'ß'] })
    end

    it 'does not return the default value if the data was parsed correctly' do
      expect(subject).to run.with_params("---\na: '1'\n", 'default_value')
                            .and_return('a' => '1')
    end
  end

  it 'raises an error with invalid YAML and no default' do
    expect(subject).to run.with_params('["one"')
                          .and_raise_error(Psych::SyntaxError)
  end

  context 'with incorrect YAML data' do
    it 'supports a structure for a default value' do
      expect(subject).to run.with_params('', 'a' => '1')
                            .and_return('a' => '1')
    end

    [1, 1.2, nil, true, false, [], {}, :yaml].each do |value|
      it "returns the default value for an incorrect #{value.inspect} (#{value.class}) parameter" do
        expect(subject).to run.with_params(value, 'default_value')
                              .and_return('default_value')
      end
    end

    context 'when running on modern rubies' do
      ['---', '...', '*8', ''].each do |value|
        it "returns the default value for an incorrect #{value.inspect} string parameter" do
          expect(subject).to run.with_params(value, 'default_value')
                                .and_return('default_value')
        end
      end
    end
  end
end
