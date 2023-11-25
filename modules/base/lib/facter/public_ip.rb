Facter.add('public_ip') do
  setcode do
    Facter.value('networking')['interfaces']['ens19']['ip']
  end
end
