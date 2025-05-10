⚙️ Step-by-Step Installation
1. Run Setup Script
bash
Copy
Edit
chmod +x setup-sepolia-node.sh
./setup-sepolia-node.sh
2. Create systemd Services
bash
Copy
Edit
cd sepolia-node
Create Geth service:
bash
Copy
Edit
nano geth-sepolia.service
# Paste Geth service code
# Save: Ctrl+X, then Y, then Enter
Create Lighthouse service:
bash
Copy
Edit
nano lighthouse-sepolia.service
# Paste Lighthouse service code
# Save: Ctrl+X, then Y, then Enter
3. Generate JWT Secret
bash
Copy
Edit
cd data
openssl rand -hex 32 > /root/sepolia-node/data/jwtsecret
cd ..
4. Enable Services
bash
Copy
Edit
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable geth-sepolia.service
sudo systemctl enable lighthouse-sepolia.service
5. Start Services (in order)
bash
Copy
Edit
sudo systemctl start geth-sepolia.service
sudo systemctl start lighthouse-sepolia.service
📄 View Logs
bash
Copy
Edit
# Geth log
sudo journalctl -u geth-sepolia.service -f

# Lighthouse log
sudo journalctl -u lighthouse-sepolia.service -f
🧪 Verify RPC Endpoints
Execution Layer (Geth)
bash
Copy
Edit
curl -X POST -H "Content-Type: application/json" \
--data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
http://localhost:8545
Expected Output:

json
Copy
Edit
{"jsonrpc":"2.0","id":1,"result":"0x6a6c3b"}
Consensus Layer (Lighthouse)
bash
Copy
Edit
curl http://localhost:5052/eth/v1/node/syncing
