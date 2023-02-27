#!/usr/bin/env bash
certs=/etc/docker/certs.d/192.168.56.1:8443
sudo rm -rf /registry-image
sudo rm -rf /etc/docker/certs
sudo rm -rf $certs

apt -y install sshpass
for i in {1..2}
  do
    sshpass -p 1234 ssh -o StrictHostKeyChecking=no root@192.168.56.$i rm -rf $certs
  done

apt remove sshpass -y
docker rm -f registry
docker rmi registry:2