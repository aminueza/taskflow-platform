# @summary Manages administrative users on bastion hosts
#
# This class manages user accounts, SSH keys, and sudo access for
# administrative users on bastion hosts. It follows the principle of
# least privilege and implements security best practices.
#
# @param users
#   Hash of users to create. Each user should have:
#   - ensure: present or absent
#   - uid: User ID
#   - gid: Group ID
#   - shell: Login shell
#   - ssh_keys: Array of SSH public keys
#   - groups: Array of additional groups
#
# @param admin_group
#   Name of the admin group for sudo access
#
# @param manage_sudo
#   Whether to manage sudo configuration
#
# @example Basic usage
#   class { 'bastion_users':
#     users => {
#       'alice' => {
#         'ensure'   => 'present',
#         'uid'      => 2001,
#         'ssh_keys' => ['ssh-ed25519 AAAA...'],
#         'groups'   => ['admin-users', 'docker'],
#       }
#     }
#   }
#
class bastion_users (
  Hash $users = {},
  String $admin_group = 'admin-users',
  Boolean $manage_sudo = true,
) {
  # Ensure admin group exists
  group { $admin_group:
    ensure => present,
    system => true,
  }

  # Configure sudo for admin group
  if $manage_sudo {
    file { '/etc/sudoers.d/admin-users':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0440',
      content => "%${admin_group} ALL=(ALL) NOPASSWD:ALL\n",
      require => Group[$admin_group],
    }
  }

  # Create users
  $users.each |String $username, Hash $user_config| {
    bastion_users::user { $username:
      * => $user_config,
    }
  }
}
