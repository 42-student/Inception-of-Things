SERVER_IP=192.168.56.110
export K3S_TOKEN="/vagrant/node-token"

MAX_RETRIES=10
SLEEP_SECONDS=5

apt-get update
apt-get install -y curl 

echo "[Worker] $(date --rfc-3339 s) Installing K3S..."
curl -sfL https://get.k3s.io | K3S_URL="https://${SERVER_IP}:6443" sh -

echo "[Worker] $(date --rfc-3339 s) $(hostname) running..."
