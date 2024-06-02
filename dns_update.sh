#!/bin/bash

# Check for correct argument usage
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 RECORD_NAME RECORD_CONTENT RECORD_TYPE"
    echo "Example: $0 subdomain.example.com 192.0.2.1 A"
    echo "Example: $0 subdomain.example.com subdomain.example.com CNAME"
    exit 1
fi

# Function to extract the root domain
extract_root_domain() {
    local domain=$1

    # Replace dots in the domain with spaces to create an array
    local parts=(${domain//./ })

    local len=${#parts[@]}
    local tld=${parts[len-1]}
    local sld=${parts[len-2]}

    # List of common second-level domains that we need to consider as part of the root domain
    local common_slds="co uk com au net org edu gov us net global io"

    # Check if the second last part of the domain is a known SLD
    if [[ " $common_slds " =~ " $sld " && $len -gt 2 ]]; then
        # If sld is in common list and there are more parts than just 'sld.tld'
        echo "${parts[len-3]}.$sld.$tld"
    else
        # Otherwise, assume the last two parts form the root domain
        echo "$sld.$tld"
    fi
}

# Cloudflare settings
RECORD_NAME=$1
RECORD_CONTENT=$2
RECORD_TYPE=$3
PROXIED=false # Change to true if you want the traffic to be proxied through Cloudflare

# Extract the root domain
ROOT_DOMAIN=$(extract_root_domain "$RECORD_NAME")

# Use a command-line password manager for API token and Zone ID retrieval
API_TOKEN=$(op read "op://dev/Cloudflare/${ROOT_DOMAIN}_api_token")
if [[ -z "$API_TOKEN" ]]; then
    echo "Failed to retrieve API token."
    exit 1
fi

ZONE_ID=$(op read "op://dev/Cloudflare/${ROOT_DOMAIN}_zone_id")
if [[ -z "$ZONE_ID" ]]; then
    echo "Failed to retrieve Zone ID for $ROOT_DOMAIN."
    exit 1
fi

# Function to get the DNS Record ID
get_record_id() {
    echo "Fetching the DNS Record ID for $RECORD_NAME..."
    RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=$RECORD_TYPE&name=$RECORD_NAME" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json" | jq -r '.result[0].id')
    echo $RECORD_ID
    if [[ "$RECORD_ID" == "null" || "$RECORD_ID" == "" ]]; then
        echo "No record found. Proceeding to create one."
        create_dns_record
    else
        echo "Record ID: $RECORD_ID found. Updating record..."
        update_dns_record
    fi
}

# Function to update DNS record
update_dns_record() {
    RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"$RECORD_TYPE\",\"name\":\"$RECORD_NAME\",\"content\":\"$RECORD_CONTENT\"}")

    if [[ $(echo $RESPONSE | jq '.success') == "true" ]]; then
        echo "DNS record updated successfully."
    else
        echo "Failed to update DNS record."
        echo "Error:"
        echo $RESPONSE | jq '.errors'
    fi
}

# Function to create DNS record
create_dns_record() {
    RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"$RECORD_TYPE\",\"name\":\"$RECORD_NAME\",\"content\":\"$RECORD_CONTENT\"}")

    if [[ $(echo $RESPONSE | jq '.success') == "true" ]]; then
        echo "DNS record created successfully."
    else
        echo "Failed to create DNS record."
        echo "Error:"
        echo $RESPONSE | jq '.errors'
    fi
}

# Main function to control flow
get_record_id