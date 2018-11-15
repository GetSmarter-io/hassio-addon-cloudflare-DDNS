#! /bin/bash
######################################################################################
# CLOUDFLARE DNS UPDATE SCRIPT
# Documentation : https://api.cloudflare.com/#dns-records-for-a-zone-list-dns-records
# Documentation : https://api.cloudflare.com/#dns-records-for-a-zone-update-dns-record
# This script use JQ as dependencies https://stedolan.github.io/jq/
# Author: @aspina
# add this script in crontab -e  eq in alpine "ln -s /config/personal-project/cloudflare-ddns/cloudflare_dns_update.sh /etc/periodic/15min/cloudflare_dns_update"
######################################################################################

CONFIG_PATH=/data/options.json

zone_identifier=$(jq --raw-output  ".zone_identifier" $CONFIG_PATH)
cloudflare_email=$(jq --raw-output  ".cloudflare_email" $CONFIG_PATH)
cloudflare_auth_key=$(jq --raw-output  ".cloudflare_auth_key" $CONFIG_PATH)
cloudflare_record_a_filter=$(jq --raw-output  ".cloudflare_record_a_filter" $CONFIG_PATH)

#hourstamp=$(date +"%F-%H")
publicip=$(curl https://api.ipify.org  2>/dev/null)

dns_records=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?type=A" -H "X-Auth-Email: $cloudflare_email" -H "X-Auth-Key: $cloudflare_auth_key" -H "Content-Type: application/json"  2>/dev/null)
dns_records_length=$(echo $dns_records | jq '.result | length')

for i in `seq 0 $((dns_records_length-1))`;
do
    dns_records_item_id=$(echo $dns_records | jq --raw-output ".result[$i].id")
    dns_records_item_name=$(echo $dns_records | jq --raw-output ".result[$i].name")
    dns_records_item_type=$(echo $dns_records | jq --raw-output ".result[$i].type")
    dns_records_item_content=$(echo $dns_records | jq --raw-output ".result[$i].content")

    if [[ $dns_records_item_name == *${cloudflare_record_a_filter}* && $dns_records_item_content != $publicip ]];
    then
        res=$(curl -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$dns_records_item_id" \
            -H "X-Auth-Email: $cloudflare_email" \
            -H "X-Auth-Key: $cloudflare_auth_key" \
            -H "Content-Type: application/json" \
            --data '{"type":'\"$dns_records_item_type\"',"name":'\"$dns_records_item_name\"',"content":'\"$publicip\"',"ttl":1,"proxied":true}'  2>/dev/null)
        echo "-> Record Updated: $dns_records_item_id: name=$dns_records_item_name type=$dns_records_item_type content=$dns_records_item_content"
    fi
done    
#printf "\n$(date) : Changed IP address of drive.dwarak.in to $publicip \n" >> /var/log/cloudflare/dns-drive-dwarak-in-update/$hourstamp.log

exit 0
