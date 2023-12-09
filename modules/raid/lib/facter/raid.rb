# SPDX-License-Identifier: Apache-2.0
require 'facter'

Facter.add('raid_mgmt_tools') do
  # ref: http://pci-ids.ucw.cz/v2.2/pci.ids
  # Run sudo lspci -nn to add missing PCI IDs, the combination of vendor ID and device ID is printed in []
  pci_ids = {
    '100010e2' => 'perccli',     # Broadcom / LSI MegaRAID 12GSAS/PCIe Secure SAS39xx (sold as Perc H750)
    '1000005b' => 'megaraid',
  }
  setcode do
    raids = []

    File.open('/proc/bus/pci/devices').each do |line|
      words = line.split
      raids.push(pci_ids[words[1]]) if pci_ids.key?(words[1])
    end
    raids.sort.uniq
  end
end

# Enable calling directly
if $PROGRAM_NAME == __FILE__
  require 'json'
  puts JSON.dump({ :raid => Facter.value('raid_mgmt_tools') })
end
