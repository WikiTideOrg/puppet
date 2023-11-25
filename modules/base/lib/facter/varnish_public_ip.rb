Facter.add('varnish_public_ip') do
  setcode do
    # Check if the node has the Role::Varnish class
    varnish_role = Facter.value(:classification)['classes'] && Facter.value(:classification)['classes'].include?('Role::Varnish')

    if varnish_role
      # Return the public IP address for nodes with Role::Varnish
      Facter.value('networking')['interfaces']['ens19']['ip']
    else
      # Return the default IP address for other nodes
      Facter.value('networking')['ip']
    end
  end
end
