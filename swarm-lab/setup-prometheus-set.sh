#!/usr/bin/env bash

# Metrica: process_cpu_seconds_total
# Metrica: engine_daemon_container_states_containers{instance="172.18.0.2:9323"} - folosire worker 2

export DOCKER_HOST=tcp://127.0.0.1:23751
docker stack deploy -c monitoring-stack.yml monitoring
docker service ls