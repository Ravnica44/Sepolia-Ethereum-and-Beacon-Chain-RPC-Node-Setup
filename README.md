## Make the script executable
`chmod +x setup-sepolia-node.sh`

## Run the script
`./setup-sepolia-node.sh`

## Go to the node folder
`cd sepolia-node`

## Modify the geth service file
`nano geth-sepolia.service` Save with: Ctrl+X → Y → Enter

## Modify the lighthouse service file
   `nano lighthouse-sepolia.service` Save with: Ctrl+X → Y → Enter

## Create JWT secret:
   `cd data`
   `openssl rand -hex 32 > /root/sepolia-node/data/jwtsecret`
   `cd ..`

## Enable systemd services:
   `sudo systemctl daemon-reexec`
   
   `sudo systemctl daemon-reload`
   
   `sudo systemctl enable geth-sepolia.service`
   
   `sudo systemctl enable lighthouse-sepolia.service`

## Start geth first:
   `sudo systemctl start geth-sepolia.service`

## Start lighthouse next:
   `sudo systemctl start lighthouse-sepolia.service`

## Check geth logs:
    `sudo journalctl -u geth-sepolia.service -f`

## Check lighthouse logs:
    `sudo journalctl -u lighthouse-sepolia.service -f`

## Test if Geth RPC is working:
    ```shell
    curl -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
    http://localhost:8546
    ```

## Allow Rpc Port:
   `sudo ufw allow 8546/tcp`
   
   `sudo ufw allow 8547/tcp`
   
   `sudo ufw allow 8551/tcp`
   
   `sudo ufw allow 5052/tcp`
   
Then enable (if not already):
   `sudo ufw enable`
   
Check status:
    `sudo ufw status`

## Test if Beacon chain is syncing:
    `curl http://localhost:5052/eth/v1/node/syncing`
