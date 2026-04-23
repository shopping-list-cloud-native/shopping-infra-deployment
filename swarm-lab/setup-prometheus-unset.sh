#!/usr/bin/env bash

unset DOCKER_HOST
docker exec swarm-manager sh -c 'mkdir -p /etc/docker && echo "{\"metrics-addr\":\"0.0.0.0:9323\",\"experimental\":true}" > /etc/docker/daemon.json'
docker exec swarm-worker-1 sh -c 'mkdir -p /etc/docker && echo "{\"metrics-addr\":\"0.0.0.0:9323\",\"experimental\":true}" > /etc/docker/daemon.json'
docker exec swarm-worker-2 sh -c 'mkdir -p /etc/docker && echo "{\"metrics-addr\":\"0.0.0.0:9323\",\"experimental\":true}" > /etc/docker/daemon.json'
docker cp prometheus.yml swarm-manager:/etc/prometheus.yml