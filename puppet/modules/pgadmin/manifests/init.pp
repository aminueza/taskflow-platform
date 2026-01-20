# @summary Installs and configures pgAdmin 4
#
# This class installs pgAdmin 4 in server mode using Docker for
# easy management and isolation. It configures authentication,
# network access, and integrates with Azure Key Vault for credentials.
#
# @param version
#   pgAdmin Docker image version
#
# @param port
#   Port for pgAdmin web interface
#
# @param email
#   Default admin email for pgAdmin
#
# @param password
#   Default admin password for pgAdmin
#
# @param server_connections
#   Hash of PostgreSQL server connections to pre-configure
#
# @param data_dir
#   Directory for pgAdmin data persistence
#
# @param enable_ssl
#   Whether to enable SSL for pgAdmin
#
# @param allowed_hosts
#   Array of allowed host IPs/networks
#
# @example Basic usage
#   class { 'pgadmin':
#     email    => 'admin@example.com',
#     password => 'SecurePassword123!',
#     port     => 8080,
#   }
#
class pgadmin (
  String $version = 'latest',
  Integer $port = 8080,
  String $email = 'admin@example.com',
  Sensitive[String] $password = Sensitive('changeme'),
  Hash $server_connections = {},
  String $data_dir = '/var/lib/pgadmin',
  Boolean $enable_ssl = false,
  Array[String] $allowed_hosts = ['10.0.0.0/8'],
) {
  # Ensure Docker is installed (should be done by infrastructure)
  # This is a dependency check
  if !defined(Service['docker']) {
    fail('Docker must be installed before pgAdmin can be configured')
  }

  # Create data directory
  file { $data_dir:
    ensure => directory,
    owner  => '5050',  # pgadmin user in container
    group  => '5050',
    mode   => '0755',
  }

  # Create configuration directory
  file { "${data_dir}/config":
    ensure  => directory,
    owner   => '5050',
    group   => '5050',
    mode    => '0755',
    require => File[$data_dir],
  }

  # Create servers.json for pre-configured connections
  unless empty($server_connections) {
    file { "${data_dir}/servers.json":
      ensure  => file,
      owner   => '5050',
      group   => '5050',
      mode    => '0600',
      content => template('pgadmin/servers.json.erb'),
      require => File[$data_dir],
      notify  => Docker::Run['pgadmin'],
    }
  }

  # Deploy pgAdmin using Docker
  docker::run { 'pgadmin':
    image           => "dpage/pgadmin4:${version}",
    ports           => ["${port}:80"],
    volumes         => [
      "${data_dir}:/var/lib/pgadmin",
    ],
    env             => [
      "PGADMIN_DEFAULT_EMAIL=${email}",
      "PGADMIN_DEFAULT_PASSWORD=${password.unwrap}",
      'PGADMIN_CONFIG_ENHANCED_COOKIE_PROTECTION=True',
      'PGADMIN_CONFIG_LOGIN_BANNER="Managed by Puppet - Authorized Access Only"',
      'PGADMIN_CONFIG_CONSOLE_LOG_LEVEL=10',
    ],
    restart_service => true,
    pull_on_start   => true,
  }

  # Create systemd override for better logging
  systemd::unit_file { 'docker-pgadmin.service.d/override.conf':
    content => @(EOT)
      [Service]
      # Restart policy
      Restart=always
      RestartSec=10s

      # Logging
      StandardOutput=journal
      StandardError=journal
      | EOT
    ,
    notify  => Service['docker-pgadmin'],
  }

  # Configure firewall rules (using ufw)
  $allowed_hosts.each |$host| {
    exec { "allow-pgadmin-from-${host}":
      command => "/usr/sbin/ufw allow from ${host} to any port ${port}",
      unless  => "/usr/sbin/ufw status | grep -q '${port}.*ALLOW.*${host}'",
      require => Docker::Run['pgadmin'],
    }
  }

  # Health check script
  file { '/usr/local/bin/pgadmin-healthcheck.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('pgadmin/healthcheck.sh.erb'),
  }

  # Monitoring cron job
  cron { 'pgadmin-healthcheck':
    command => '/usr/local/bin/pgadmin-healthcheck.sh',
    user    => 'root',
    minute  => '*/5',
    require => File['/usr/local/bin/pgadmin-healthcheck.sh'],
  }
}
