#!/usr/bin/env bash
echo "Cloudflare DDNS every 10 minutes"

while true; do /cloudflare_dns_update.sh; sleep 600; done;