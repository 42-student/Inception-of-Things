SERVER_IP=192.168.56.110
export K3S_TOKEN_FILE="/vagrant/node-token"

MAX_RETRIES=10
SLEEP_TIME=5

apt-get update
apt-get install -y curl 

echo "[Worker] $(date --rfc-3339 s) Waiting for token..."

try=0
while [ $try -lt $MAX_RETRIES ]; do
	if [ -f "${K3S_TOKEN_FILE}" ]; then
		break
	else
		sleep $SLEEP_TIME
		try=$((try+1))
	fi
done
if [ $try -eq $MAX_RETRIES ]; then
	echo "[Worker] ERROR: Token not found. Max retries exceeded. Exiting..."
	exit 1
fi

echo "[Worker] $(date --rfc-3339 s) Installing K3S..."
curl -sfL https://get.k3s.io | K3S_URL="https://${SERVER_IP}:6443" sh -

echo "[Worker] $(date --rfc-3339 s) $(hostname) running..."
