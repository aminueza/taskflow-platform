# @summary Creates and manages individual administrative users
#
# @param ensure
#   Whether the user should be present or absent
#
# @param uid
#   User ID number
#
# @param gid
#   Primary group ID
#
# @param shell
#   Login shell
#
# @param ssh_keys
#   Array of SSH public keys
#
# @param groups
#   Additional groups for the user
#
# @param home
#   Home directory path
#
# @param managehome
#   Whether to manage the home directory
#
# @example
#   bastion_users::user { 'alice':
#     ensure   => present,
#     uid      => 2001,
#     ssh_keys => ['ssh-ed25519 AAAA...'],
#     groups   => ['admin-users'],
#   }
#
define bastion_users::user (
  Enum['present', 'absent'] $ensure = 'present',
  Optional[Integer] $uid = undef,
  Optional[Integer] $gid = undef,
  String $shell = '/bin/bash',
  Array[String] $ssh_keys = [],
  Array[String] $groups = ['admin-users'],
  Optional[String] $home = undef,
  Boolean $managehome = true,
) {
  $username = $title
  $home_dir = $home ? {
    undef   => "/home/${username}",
    default => $home,
  }

  # Create user account
  user { $username:
    ensure     => $ensure,
    uid        => $uid,
    gid        => $gid,
    shell      => $shell,
    home       => $home_dir,
    managehome => $managehome,
    groups     => $groups,
    comment    => "Managed by Puppet - ${username}",
  }

  # Manage SSH authorized keys
  if $ensure == 'present' and !empty($ssh_keys) {
    file { "${home_dir}/.ssh":
      ensure  => directory,
      owner   => $username,
      group   => $username,
      mode    => '0700',
      require => User[$username],
    }

    file { "${home_dir}/.ssh/authorized_keys":
      ensure  => file,
      owner   => $username,
      group   => $username,
      mode    => '0600',
      content => join($ssh_keys.map |$key| { "${key}\n" }, ''),
      require => File["${home_dir}/.ssh"],
    }

    # Create user's bashrc with security best practices
    file { "${home_dir}/.bashrc":
      ensure  => file,
      owner   => $username,
      group   => $username,
      mode    => '0644',
      content => template('bastion_users/bashrc.erb'),
      require => User[$username],
    }

    # Set up user audit logging
    file { "${home_dir}/.bash_history":
      ensure  => file,
      owner   => $username,
      group   => $username,
      mode    => '0600',
      require => User[$username],
    }
  }

  # Remove home directory when user is absent
  if $ensure == 'absent' {
    file { $home_dir:
      ensure  => absent,
      force   => true,
      backup  => false,
      require => User[$username],
    }
  }
}
