# === Class base::memory_cgroup
class base::memory_cgroup {
    # Enable memory cgroup
    grub::bootparam { 'cgroup_enable':
        value => 'memory',
    }

    grub::bootparam { 'swapaccount':
        value => '1',
    }
}