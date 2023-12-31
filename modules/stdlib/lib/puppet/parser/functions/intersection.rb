# frozen_string_literal: true

#
# intersection.rb
#
module Puppet::Parser::Functions
  newfunction(:intersection, type: :rvalue, doc: <<-DOC
    @summary
      This function returns an array of the intersection of two.

    @return
      an array of the intersection of two.

    @example Example Usage:
      intersection(["a","b","c"],["b","c","d"])  # returns ["b","c"]
      intersection(["a","b","c"],[1,2,3,4])      # returns [] (true, when evaluated as a Boolean)
  DOC
  ) do |arguments|
    # Two arguments are required
    raise(Puppet::ParseError, "intersection(): Wrong number of arguments given (#{arguments.size} for 2)") if arguments.size != 2

    first = arguments[0]
    second = arguments[1]

    raise(Puppet::ParseError, "intersection(): Requires 2 arrays, got #{first.class} and #{second.class}") unless first.is_a?(Array) && second.is_a?(Array)

    result = first & second

    return result
  end
end

# vim: set ts=2 sw=2 et :
