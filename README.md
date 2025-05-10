Step 1: Run Setup Script
chmod +x setup-sepolia-node.sh
./setup-sepolia-node.sh
Step 2: Create systemd Services
cd sepolia-node
nano geth-sepolia.service
# Paste Geth service code
# Save: Ctrl+X, then Y, Enter
nano lighthouse-sepolia.service
# Paste Lighthouse service code
# Save: Ctrl+X, then Y, Enter
Step 3: Generate JWT Secret
cd data
openssl rand -hex 32 > /root/sepolia-node/data/jwtsecret
cd ..
Step 4: Enable Services
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable geth-sepolia.service
sudo systemctl enable lighthouse-sepolia.service
Step 5: Start Services
sudo systemctl start geth-sepolia.service
sudo systemctl start lighthouse-sepolia.service
View Logs
# Geth log
sudo journalctl -u geth-sepolia.service -f
# Lighthouse log
sudo journalctl -u lighthouse-sepolia.service -f
Verify RPC Endpoints
# Execution Layer (Geth)
curl -X POST -H "Content-Type: application/json" \
--data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
http://localhost:8545
Expected Output:
{"jsonrpc":"2.0","id":1,"result":"0x6a6c3b"}
# Consensus Layer (Lighthouse)
curl http://localhost:5052/eth/v1/node/syncing
Done
Your Sepolia node is fully running with both Execution and Consensus clients!
