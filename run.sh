#!/usr/bin/env bash
echo "Cloudflare DDNS every 15min"

while true; do /cloudflare_dns_update.sh; sleep 600; done;