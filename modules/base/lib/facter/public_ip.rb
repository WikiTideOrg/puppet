require 'facter'

Facter.add('public_ip') do
  setcode do
    interface = 'ens19'
    ip = Facter.value("networking.interfaces.#{interface}.ip")
    ip6 = Facter.value("networking.interfaces.#{interface}.ip6")

    {
      'ip' => ip,
      'ip6' => ip6,
    }
  end
end
