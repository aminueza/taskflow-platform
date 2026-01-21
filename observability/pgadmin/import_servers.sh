#!/bin/bash

# Wait for pgAdmin to be ready
sleep 5

# Import server configuration using pgAdmin CLI
python /pgadmin4/setup.py --load-servers /pgadmin4/servers.json --user admin@devops.local

# Store the password in pgAdmin's password storage
PGADMIN_SETUP_EMAIL=admin@devops.local PGADMIN_SETUP_PASSWORD=admin python3 << 'EOF'
import sys
sys.path.insert(0, '/pgadmin4')

from pgadmin.model import db, Server, User
from pgadmin.utils.crypto import encrypt
from config import config
from flask import Flask

# Create Flask app
app = Flask(__name__)
app.config.from_object(config['development'])
db.init_app(app)

with app.app_context():
    user = User.query.filter_by(email='admin@devops.local').first()
    if user:
        server = Server.query.filter_by(user_id=user.id).first()
        if server:
            # Encrypt and store the password
            password = 'a64afa3a0411e129bd02635817621120a5af2efb92dec8fe0a02fa02a3c2fff1'
            server.password = encrypt(password, user.password)
            db.session.commit()
            print("Password stored successfully")
EOF
