#!/bin/bash

# Sepolia Ethereum & Beacon Chain Private RPC Node Setup
# This script sets up both execution client (ETH) and consensus client (Beacon Chain) for Sepolia testnet

set -e

# Create directories
mkdir -p ~/sepolia-node/{geth,lighthouse,data,logs}
cd ~/sepolia-node

echo "======================================================"
echo "Setting up Sepolia Private RPC Node (ETH + Beacon Chain)"
echo "======================================================"

# Install dependencies
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y build-essential git wget software-properties-common cmake clang

# Install Go (required for Geth)
if ! command -v go &> /dev/null; then
    echo "Installing Go..."
    wget https://go.dev/dl/go1.21.3.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.3.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
    source ~/.profile
    rm go1.21.3.linux-amd64.tar.gz
fi

# Install Rust (required for Lighthouse)
if ! command -v rustc &> /dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
fi

# Install and configure Geth (Execution Client)
if ! command -v geth &> /dev/null; then
    echo "Installing Geth execution client..."
    sudo add-apt-repository -y ppa:ethereum/ethereum
    sudo apt-get update
    sudo apt-get install -y ethereum
else
    echo "Geth already installed, skipping..."
fi

# Install Lighthouse (Consensus Client)
if ! command -v lighthouse &> /dev/null; then
    echo "Installing Lighthouse consensus client..."
    cd ~/sepolia-node
    git clone https://github.com/sigp/lighthouse.git
    cd lighthouse
    git checkout stable
    make
    cd ..
else
    echo "Lighthouse already installed, skipping..."
fi

# Create Geth service file
cat > ~/sepolia-node/geth-sepolia.service << EOF
[Unit]
Description=Go Ethereum Client - Sepolia Testnet
After=network.target
Wants=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/bin/geth --sepolia --http --http.api eth,net,engine,admin --http.addr 0.0.0.0 --http.port 8545 --http.corsdomain "*" --ws --ws.addr 0.0.0.0 --ws.port 8546 --ws.api eth,net,engine --ws.origins "*" --datadir ~/sepolia-node/data/geth --authrpc.addr 0.0.0.0 --authrpc.port 8551 --authrpc.vhosts "*" --authrpc.jwtsecret ~/sepolia-node/data/jwtsecret
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=default.target
EOF

# Create Lighthouse service file
cat > ~/sepolia-node/lighthouse-sepolia.service << EOF
[Unit]
Description=Lighthouse Ethereum Client - Sepolia Testnet
After=network.target geth-sepolia.service
Wants=network.target geth-sepolia.service

[Service]
User=$USER
Type=simple
ExecStart=$HOME/.cargo/bin/lighthouse bn --network sepolia --datadir ~/sepolia-node/data/lighthouse --execution-endpoint http://localhost:8551 --execution-jwt ~/sepolia-node/data/jwtsecret --checkpoint-sync-url https://checkpoint-sync.sepolia.ethpandaops.io --http --http.address 0.0.0.0 --http.port 5052 --metrics --metrics-address 0.0.0.0 --metrics-port 5054
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=default.target
EOF

# Generate JWT Secret for communication between execution and consensus clients
echo "Generating JWT secret for secure client communication..."
openssl rand -hex 32 > ~/sepolia-node/data/jwtsecret

# Install services
echo "Installing services..."
sudo cp ~/sepolia-node/geth-sepolia.service /etc/systemd/system/
sudo cp ~/sepolia-node/lighthouse-sepolia.service /etc/systemd/system/
sudo systemctl daemon-reload

# Create start script
cat > ~/sepolia-node/start-sepolia-node.sh << EOF
#!/bin/bash
echo "Starting Sepolia Ethereum Node (Execution + Consensus)"
sudo systemctl start geth-sepolia
echo "Waiting for Geth to initialize (30 seconds)..."
sleep 30
sudo systemctl start lighthouse-sepolia
echo "Sepolia node services started!"
echo "RPC Endpoints:"
echo "- Execution (ETH) HTTP RPC: http://localhost:8545"
echo "- Execution (ETH) WebSocket: ws://localhost:8546"
echo "- Consensus (Beacon) HTTP: http://localhost:5052"
echo "Monitor logs:"
echo "- Execution: sudo journalctl -fu geth-sepolia"
echo "- Consensus: sudo journalctl -fu lighthouse-sepolia"
EOF

# Create stop script
cat > ~/sepolia-node/stop-sepolia-node.sh << EOF
#!/bin/bash
echo "Stopping Sepolia Ethereum Node services..."
sudo systemctl stop lighthouse-sepolia
sudo systemctl stop geth-sepolia
echo "Services stopped!"
EOF

# Make scripts executable
chmod +x ~/sepolia-node/start-sepolia-node.sh
chmod +x ~/sepolia-node/stop-sepolia-node.sh

echo "======================================================"
echo "Setup completed successfully!"
echo "======================================================"
echo ""
echo "To start your Sepolia node:"
echo "  ~/sepolia-node/start-sepolia-node.sh"
echo ""
echo "To stop your Sepolia node:"
echo "  ~/sepolia-node/stop-sepolia-node.sh"
echo ""
echo "RPC Endpoints once started:"
echo "- Execution (ETH) HTTP RPC: http://localhost:8545"
echo "- Execution (ETH) WebSocket: ws://localhost:8546"
echo "- Consensus (Beacon) HTTP: http://localhost:5052"
echo ""
echo "Initial synchronization may take several hours to complete."
echo "You can monitor sync progress using the following commands:"
echo "- Execution client: sudo journalctl -fu geth-sepolia"
echo "- Consensus client: sudo journalctl -fu lighthouse-sepolia"
