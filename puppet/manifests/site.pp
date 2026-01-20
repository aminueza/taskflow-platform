# Bastion Host Configuration
# Manages users and pgAdmin deployment

node 'bastion' {
  # Manage admin users with SSH keys
  include bastion_users

  # Deploy pgAdmin for database management
  include pgadmin
}

# Default node configuration
node default {
  notify { 'No configuration for this node': }
}
