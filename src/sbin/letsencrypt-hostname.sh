#!/bin/bash -e
### Copyright 1999-2016. Parallels IP Holdings GmbH.
### Secure plesk clean installation with hostname certificate by Let's Encrypt

export PYTHONWARNINGS="ignore:Non-standard path"
LE_HOME=${LE_HOME:-"/usr/local/psa/var/modules/letsencrypt"}
DOMAIN=${1:-`hostname`}
EMAIL=$2

if [ -f "${LE_HOME}/cli.ini" ]; then
    CONFIG="--config ${LE_HOME}/cli.ini"
else
    CONFIG=""
fi

if [ -z "${EMAIL}" ]; then
    EMAIL_OPT="--register-unsafely-without-email"
else
    EMAIL_OPT="--email ${EMAIL}"
fi

"${LE_HOME}/venv/bin/letsencrypt" $CONFIG \
    --renew-by-default \
    --non-interactive \
    --no-redirect \
    --agree-tos \
    --text \
    --config-dir "${LE_HOME}/root/etc" \
    --work-dir "${LE_HOME}/root/lib" \
    --logs-dir "${LE_HOME}/root/logs" \
    --webroot \
    --webroot-path "/var/www/vhosts/default/htdocs/" \
    -d "${DOMAIN}" \
    $EMAIL_OPT \
    certonly

CERT_PATH="${LE_HOME}/root/etc/live/${DOMAIN}"
TMP_PATH=$(mktemp "${CERT_PATH}/plesk.XXXXX")
cat "${CERT_PATH}/privkey.pem" <(echo) \
    "${CERT_PATH}/cert.pem" <(echo) \
    "${CERT_PATH}/chain.pem" > "${TMP_PATH}"
echo "Let's Encrypt certificate for Plesk was created: ${TMP_PATH}"
/usr/local/psa/admin/bin/certmng --setup-cp-certificate --certificate="${TMP_PATH}"
echo "Certificate installation was finished successfully"
