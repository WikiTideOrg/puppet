require 'facter'

Facter.add('public_ip') do
  setcode do
    interface = 'ens19'
    ip = Facter.value("networking.interfaces.ens19.ip")
    ip6 = Facter.value("networking.interfaces.ens19.ip6")

    {
      'ip' => ip,
      'ip6' => ip6,
    }
  end
end
