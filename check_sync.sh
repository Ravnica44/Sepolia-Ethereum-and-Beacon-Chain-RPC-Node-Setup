#!/bin/bash

# === Assumes the API key is exported as an environment variable ===
if [ -z "$ETHERSCAN_API_KEY" ]; then
    echo "❌ ETHERSCAN_API_KEY is not set. Please export it before running the script."
    exit 1
fi

while true; do
    echo "------ $(date) ------"

    # Get local block
    local_block_hex=$(curl -s -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
    http://localhost:8546 | jq -r '.result')

    local_block=$((local_block_hex))

    # Get network block from Etherscan
    remote_block_hex=$(curl -s "https://api-sepolia.etherscan.io/api?module=proxy&action=eth_blockNumber&apikey=$ETHERSCAN_API_KEY" | jq -r '.result')

    remote_block=$((remote_block_hex))

    # Display and compare
    echo "Local block  : $local_block"
    echo "Network block: $remote_block"

    if [ "$remote_block" -eq 0 ]; then
        echo "❌ Failed to get remote block. Check API key or network."
    elif [ "$local_block" -ge "$remote_block" ]; then
        echo "✅ Node is fully synced."
    else
        echo "⏳ Syncing... $((remote_block - local_block)) blocks behind."
    fi

    echo ""  # Blank line for readability
    sleep 60
done
