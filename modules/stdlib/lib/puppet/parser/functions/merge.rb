# frozen_string_literal: true

#
# merge.rb
#
module Puppet::Parser::Functions
  newfunction(:merge, type: :rvalue, doc: <<-DOC) do |args|
    @summary
      Merges two or more hashes together and returns the resulting hash.

    @example **Usage**
      $hash1 = {'one' => 1, 'two', => 2}
      $hash2 = {'two' => 'dos', 'three', => 'tres'}
      $merged_hash = merge($hash1, $hash2) # $merged_hash =  {'one' => 1, 'two' => 'dos', 'three' => 'tres'}

    When there is a duplicate key, the key in the rightmost hash will "win."

    @return [Hash]
      The merged hash

    Note that since Puppet 4.0.0 the same merge can be achieved with the + operator.
      `$merged_hash = $hash1 + $hash2`
  DOC

    raise Puppet::ParseError, "merge(): wrong number of arguments (#{args.length}; must be at least 2)" if args.length < 2

    # The hash we accumulate into
    accumulator = {}
    # Merge into the accumulator hash
    args.each do |arg|
      next if arg.is_a?(String) && arg.empty? # empty string is synonym for puppet's undef
      raise Puppet::ParseError, "merge: unexpected argument type #{arg.class}, only expects hash arguments" unless arg.is_a?(Hash)

      accumulator.merge!(arg)
    end
    # Return the fully merged hash
    accumulator
  end
end
