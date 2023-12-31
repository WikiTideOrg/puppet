# frozen_string_literal: true

#
# dirname.rb
#
module Puppet::Parser::Functions
  newfunction(:dirname, type: :rvalue, doc: <<-DOC
    @summary
      Returns the dirname of a path.

    @return [String] the given path's dirname
  DOC
  ) do |arguments|
    raise(Puppet::ParseError, 'dirname(): No arguments given') if arguments.empty?
    raise(Puppet::ParseError, "dirname(): Too many arguments given (#{arguments.size})") if arguments.size > 1
    raise(Puppet::ParseError, 'dirname(): Requires string as argument') unless arguments[0].is_a?(String)
    # undef is converted to an empty string ''
    raise(Puppet::ParseError, 'dirname(): Requires a non-empty string as argument') if arguments[0].empty?

    return File.dirname(arguments[0])
  end
end

# vim: set ts=2 sw=2 et :
