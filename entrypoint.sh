#!/bin/sh

set -x

SSL_DIR=/etc/squid/ssl_certs
PASSPHRASE=""

# ###########################
# Gernerate SSL Certificate
# ###########################
echo "Generate SSL Certficate"
mkdir -p ${SSL_DIR}

if [ ! -f ${SSL_DIR}/squid.crt -o ! -f ${SSL_DIR}/squid.key ]; then

    # Generate our Private Key, CSR and Certificate
    openssl genrsa -out "${SSL_DIR}/squid.key" -passout pass:$PASSPHRASE 2048
    openssl req -new -subj '/CN=squid/O=squid/C=XX' -key "${SSL_DIR}/squid.key" -out "${SSL_DIR}/squid.csr" -passin pass:$PASSPHRASE -nodes
    openssl x509 -passin pass:$PASSPHRASE -req -days 3650 -in "${SSL_DIR}/squid.csr" -signkey "${SSL_DIR}/squid.key" -out "${SSL_DIR}/squid.crt"

    chmod 700 ${SSL_DIR}
    chmod 600 ${SSL_DIR}/squid.key
else
    echo "Reusing existing certificate"
fi

chown squid:squid /etc/squid/ssl_certs/*

echo '# ########################################################################'
echo '# Import the following certificate'
echo '# ########################################################################'
echo.
openssl x509 -sha1 -in ${SSL_DIR}/squid.crt -fingerprint
echo.
echo '# ########################################################################'

# ########################
# Initialize Squid Cache
# ########################
# Make sure our cache is setup
# -z        Create missing swap directories and then exit.
[ -e /var/cache/squid/swap.state ] || squid -z 2>/dev/null
chown -R squid:squid /var/cache/squid/

sleep 5

# ########################
# setup ssl db
# to initialize ssl_db the folder ssl_db must not exist
# ########################
rm -rf /var/lib/ssl_db
/usr/lib/squid/ssl_crtd -c -s /var/lib/ssl_db
chown squid:squid -R /var/lib/ssl_db

# setup log folder
if [ ! -e /var/log/squid/access.log -o ! -e /var/log/squid/cache.log ]; then
    touch /var/log/squid/access.log /var/log/squid/cache.log
fi
chown squid:squid -R /var/log/squid

# ########################
# Start Squid
# ########################
# -N        No daemon mode.
# -Y        Only return UDP_HIT or UDP_MISS_NOFETCH during fast reload.
# -C        Do not catch fatal signals.
# -d level  Write debugging to stderr also.
squid -NYCd 1

tail -f /var/log/squid/access.log /var/log/squid/cache.log
