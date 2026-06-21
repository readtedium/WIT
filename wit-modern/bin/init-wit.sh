#!/bin/bash
# WIT Startup Script
# Initializes the WIT data directory and admin user

set -e

WIT_ROOT=${WIT_ROOT:-/opt/wit}
WIT_DATA=${WIT_ROOT}/data
ADMIN_DIR=${WIT_DATA}/Discussion/Admin
PEOPLE_DIR=${ADMIN_DIR}/People
PASSWD_FILE=${ADMIN_DIR}/passwd

echo "Initializing WIT data directory..."

# Create directory structure
mkdir -p "${WIT_DATA}/Discussion/Topics"
mkdir -p "${ADMIN_DIR}"
mkdir -p "${PEOPLE_DIR}"

# Initialize admin password file if it doesn't exist
if [ ! -f "${PASSWD_FILE}" ]; then
    touch "${PASSWD_FILE}"
    echo "Created empty password file at ${PASSWD_FILE}"
fi

# Initialize htpasswd file if it doesn't exist
HTPASSWD_FILE="${ADMIN_DIR}/htpasswd"
if [ ! -f "${HTPASSWD_FILE}" ]; then
    touch "${HTPASSWD_FILE}"
    echo "Created empty htpasswd file at ${HTPASSWD_FILE}"
fi

# Create README for the discussion area if it doesn't exist
if [ ! -f "${WIT_DATA}/Discussion/README" ]; then
    cat > "${WIT_DATA}/Discussion/README" <<'EOF'
<h2>Welcome to WIT - W3 Interactive Talk</h2>
<p>This is a historical recreation of the WIT (W3 Interactive Talk) software,
originally created by Ari Luotonen at CERN in June 1994.</p>

<p>WIT was one of the first web-based discussion forums, allowing users to:</p>
<ul>
    <li>Create topics for discussion</li>
    <li>Add proposals to topics</li>
    <li>Argue for or against proposals</li>
    <li>Build threaded discussions</li>
</ul>

<p>To get started:</p>
<ol>
    <li><a href="/cgi-bin/wit-subscribe">Subscribe</a> to create your username</li>
    <li>Browse existing topics or create a new one</li>
    <li>Join the discussion!</li>
</ol>

<p><em>This software is a piece of web history - enjoy it!</em></p>
EOF
    echo "Created discussion README"
fi

# Set permissions - Apache runs as www-data
chown -R www-data:www-data "${WIT_DATA}"
chmod -R 755 "${WIT_DATA}"
chmod 644 "${PASSWD_FILE}" 2>/dev/null || true

echo "WIT initialization complete!"
echo ""
echo "Access WIT at: http://localhost/"
echo "Subscribe at: http://localhost/cgi-bin/wit-subscribe"
