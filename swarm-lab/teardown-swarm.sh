#!/usr/bin/env bash

set -euo pipefail

unset DOCKER_HOST
docker context use default >/dev/null 2>&1 || true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

MANAGER_HOST="tcp://127.0.0.1:23751"
WORKER1_HOST="tcp://127.0.0.1:23752"
WORKER2_HOST="tcp://127.0.0.1:23753"

echo "Verificare stack..."
if docker -H "${MANAGER_HOST}" stack ls 2>/dev/null | grep -q shopping; then
  echo "Șterg stack-ul 'shopping'..."
  docker -H "${MANAGER_HOST}" stack rm shopping
  sleep 5
else
  echo "Stack-ul 'shopping' nu rulează sau managerul nu este disponibil."
fi

echo
read -p "Vrei reset complet al swarm-lab? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Scot workerii din swarm..."
  docker -H "${WORKER1_HOST}" swarm leave --force 2>/dev/null || true
  docker -H "${WORKER2_HOST}" swarm leave --force 2>/dev/null || true

  echo "Scot managerul din swarm..."
  docker -H "${MANAGER_HOST}" swarm leave --force 2>/dev/null || true

  echo "Opresc și șterg containerele + volumele dind..."
  docker compose -f "${SCRIPT_DIR}/docker-compose.yml" down -v --remove-orphans

  echo "Șterg containere rămase, dacă există..."
  docker rm -f swarm-manager swarm-worker-1 swarm-worker-2 2>/dev/null || true

  echo "Șterg volume rămase din swarm-lab, dacă există..."
  docker volume ls -q | grep '^swarm-lab_' | xargs -r docker volume rm

  echo
  echo "Reset complet făcut."
  echo "Pentru a reporni:"
  echo "  cd ${SCRIPT_DIR}"
  echo "  ./setup-swarm.sh"
else
  echo "Swarm-ul rămâne activ. Poți redeploy cu:"
  echo "  export DOCKER_HOST=${MANAGER_HOST}"
  echo "  cd ${INFRA_DIR}"
  echo "  docker stack deploy -c docker-stack.yml shopping"
fi

echo
echo "Verificare containere swarm:"
docker ps -a | grep swarm || true

echo
echo "Verificare volume swarm-lab:"
docker volume ls | grep swarm-lab || true