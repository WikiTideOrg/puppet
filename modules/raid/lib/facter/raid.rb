# SPDX-License-Identifier: Apache-2.0
require 'facter'

Facter.add('raid_mgmt_tools') do
  # ref: http://pci-ids.ucw.cz/v2.2/pci.ids
  # Run sudo lspci -nn to add missing PCI IDs, the combination of vendor ID and device ID is printed in []
  pci_ids = {
    '100010e2' => 'perccli',     # Broadcom / LSI MegaRAID 12GSAS/PCIe Secure SAS39xx (sold as Perc H750)
    '1000005d' => 'megaraid',    # LSI Logic / Symbios Logic MegaRAID SAS-3 3108, also shows up as
                                 # Broadcom / LSI MegaRAID SAS-3 3108 [Invader]
    '100000cf' => 'megaraid',    # Broadcom / LSI MegaRAID SAS-3 3324 [Intruder] (rev 01)
    '10000016' => 'megaraid',    # Broadcom / LSI MegaRAID Tri-Mode SAS3508
    '10000014' => 'megaraid',    # LSI Logic / Symbios Logic MegaRAID Tri-Mode SAS3516
  }
  setcode do
    raids = []

    File.open('/proc/bus/pci/devices').each do |line|
      words = line.split
      raids.push(pci_ids[words[1]]) if pci_ids.key?(words[1])
    end

    if File.exists?('/proc/mdstat') && File.open('/proc/mdstat').grep(/md\d+\s+:\s+active/)
      raids.push('md')
    end
    raids.sort.uniq
  end
end

# Enable calling directly as a bypass
if $PROGRAM_NAME == __FILE__
  require 'json'
  puts JSON.dump({ :raid => Facter.value('raid_mgmt_tools') })
end
