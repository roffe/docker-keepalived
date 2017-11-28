#!/usr/bin/env bash

# Default settings

# KEEPALIVED_CHECK_HOST url/hostname/ip to check
# KEEPALIVED_CHECK_PORT destination port for type TCP
# KEEPALIVED_CHECK_TYPE CURL/TCP

KEEPALIVED_CHECK_HOST=${KEEPALIVED_CHECK_HOST:-"https://10.1.201.101"}
KEEPALIVED_CHECK_PORT=${KEEPALIVED_CHECK_PORT:-80}
KEEPALIVED_CHECK_TYPE=${KEEPALIVED_CHECK_TYPE:-curl}
KEEPALIVED_CHECK_CURL_OPTS=${KEEPALIVED_CHECK_CURL_OPTS}
KEEPALIVED_CHECK_CURL_CACERT=${KEEPALIVED_CHECK_CURL_CACERT}

# check if $BASH_VERSION is set at all
if [ -z $BASH_VERSION ]; then
    output "Bash version not found"
    exit 1
fi

# If it's set, check the version
case $BASH_VERSION in 
    4.*) 
    ;;
    ?) 
    output "Bash version < 4.* please upgrade"
    exit 1
    ;; 
esac

REQUIRED=('KEEPALIVED_CHECK_HOST' 'KEEPALIVED_CHECK_PORT' 'KEEPALIVED_CHECK_TYPE')
for REQ in "${REQUIRED[@]}"; do
	if [ -z "$(eval echo \$$REQ)" ]; then
		output "Missing required config value: ${REQ}"
		exit 1
	fi
done

function output() {
    echo "$1" > /proc/1/fd/1
}

function check_curl() {
    if [ ! -z ${KEEPALIVED_CHECK_CURL_CACERT} ]; then
    local CACERT=('--cacert' "${KEEPALIVED_CHECK_CURL_CACERT}")
    fi

    curl -s "${KEEPALIVED_CHECK_HOST}" ${KEEPALIVED_CHECK_CURL_OPTS} ${CACERT[@]} -o /dev/null
    case "${?}" in
        0)
            output "Curl check OK"
            exit 0
            ;;
        1)
            output "/!\ Curl check failed"
            exit 1
            ;;
        60)
            output "/!\ Curl check failed, unable to get local issuer certificate!"
            exit 1
            ;;
    esac

}

function check_tcp() {
    echo "TCP"
}

case "${KEEPALIVED_CHECK_TYPE,,}" in
    curl)
        check_curl
        ;;
    tcp)
        check_tcp
        ;;
    *)
        output "only CURL or TCP supported"
        exit 1
esac