#!/usr/bin/env bash
certs=/etc/docker/certs.d/192.168.56.1:8443
sudo mkdir /registry-image
sudo mkdir /etc/docker/certs
sudo mkdir -p $certs
sudo openssl req -x509 -config $(dirname "$0")/tls.csr -nodes -newkey rsa:4096 \
-keyout tls.key -out tls.crt -days 365 -extensions v3_req

sudo apt -y install sshpass
for i in {1..2}
  do
    sudo sshpass -p 1234 ssh -o StrictHostKeyChecking=no root@192.168.56.$i mkdir -p $certs
    sudo sshpass -p 1234 scp tls.crt 192.168.56.$i:$certs
  done
  
sudo cp tls.crt $certs
sudo mv tls.* /etc/docker/certs

docker run -d \
  --restart=always \
  --name registry \
  -v /etc/docker/certs:/docker-in-certs:ro \
  -v /registry-image:/var/lib/registry \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/docker-in-certs/tls.crt \
  -e REGISTRY_HTTP_TLS_KEY=/docker-in-certs/tls.key \
  -p 8443:443 \
  registry:2