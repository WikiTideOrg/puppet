
Facter.add('varnish_ip_override') do
  setcode do
    networking = Facter.value('networking')

    if networking
      if networking['interfaces']
        if networking['interfaces']['ens19']
          if networking['interfaces']['ens19']['ip']
            varnish_role = Facter.value(:classification)['classes'] && Facter.value(:classification)['classes'].include?('Role::Varnish')

            if varnish_role
              # Return the overridden IP address for nodes with Role::Varnish
              networking['interfaces']['ens19']['ip']
            else
              # Return the default IP address for other nodes
              networking['ip']
            end
          else
            # Print a debug message if 'ip' is nil
            warn "The 'ip' key for 'ens19' is nil."
            'fallback_value'
          end
        else
          # Print a debug message if 'ens19' is nil
          warn "The 'ens19' key in 'interfaces' is nil."
          'fallback_value'
        end
      else
        # Print a debug message if 'interfaces' is nil
        warn "The 'interfaces' key is nil."
        'fallback_value'
      end
    else
      # Print a debug message if 'networking' is nil
      warn "The 'networking' fact is nil."
      'fallback_value'
    end
  end
end
