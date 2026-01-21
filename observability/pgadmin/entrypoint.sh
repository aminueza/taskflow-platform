#!/bin/bash

# Create pgpass file in the correct location with proper permissions
mkdir -p /var/lib/pgadmin/storage/admin_devops.local
cat > /var/lib/pgadmin/storage/admin_devops.local/pgpassfile << 'EOF'
postgres:5432:*:postgres:a64afa3a0411e129bd02635817621120a5af2efb92dec8fe0a02fa02a3c2fff1
EOF

# Set correct permissions (must be 0600)
chmod 600 /var/lib/pgadmin/storage/admin_devops.local/pgpassfile
chown pgadmin:pgadmin /var/lib/pgadmin/storage/admin_devops.local/pgpassfile

# Execute the original entrypoint
exec /entrypoint.sh
