Facter.add('varnish_ip_override') do
  setcode do
    networking = Facter.value('networking')

    if networking && networking['interfaces'] && networking['interfaces']['ens19'] && networking['interfaces']['ens19']['ip']
      varnish_role = Facter.value(:classification)['classes'] && Facter.value(:classification)['classes'].include?('Role::Varnish')

      if varnish_role
        # Return the overridden IP address for nodes with Role::Varnish
        networking['interfaces']['ens19']['ip']
      else
        # Return the default IP address for other nodes
        networking['ip']
      end
    else
      # Return a default value if the keys are not present
      'fallback_value'
    end
  end
end
