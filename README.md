1. Make the script executable:
   chmod +x setup-sepolia-node.sh

2. Run the script:
   ./setup-sepolia-node.sh

3. Go to the node folder:
   cd sepolia-node

4. Create the geth service file:
   nano geth-sepolia.service
   [Paste code]
   Save with: Ctrl+X → Y → Enter

5. Create the lighthouse service file:
   nano lighthouse-sepolia.service
   [Paste code]
   Save with: Ctrl+X → Y → Enter

6. Create JWT secret:
   cd data
   openssl rand -hex 32 > /root/sepolia-node/data/jwtsecret
   cd ..

7. Enable systemd services:
   sudo systemctl daemon-reexec
   sudo systemctl daemon-reload
   sudo systemctl enable geth-sepolia.service
   sudo systemctl enable lighthouse-sepolia.service

8. Start geth first:
   sudo systemctl start geth-sepolia.service

9. Start lighthouse next:
   sudo systemctl start lighthouse-sepolia.service

10. Check geth logs:
    sudo journalctl -u geth-sepolia.service -f

11. Check lighthouse logs:
    sudo journalctl -u lighthouse-sepolia.service -f

12. Test if Geth RPC is working:
    curl -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
    http://localhost:8545

13. Allow Rpc Port:
   sudo ufw allow 8545/tcp,
   sudo ufw allow 8551/tcp,
   sudo ufw allow 5052/tcp
14. Then enable (if not already):
   sudo ufw enable
15. Check status:
    sudo ufw status



13. Test if Beacon chain is syncing:
    curl http://localhost:5052/eth/v1/node/syncing
