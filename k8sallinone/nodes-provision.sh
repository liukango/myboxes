#!/bin/bash

systemctl disable firewalld
systemctl stop firewalld

yum install -y etcd kubernetes

cat > /etc/docker/daemon.json << EOF
{
    "registry-mirrors": [
        "http://a4e6a79f.m.daocloud.io"
    ],
    "insecure-registries": []
}
EOF

systemctl enable etcd
systemctl enable docker
systemctl enable kube-apiserver
systemctl enable kube-controller-manager
systemctl enable kube-scheduler
systemctl enable kubelet
systemctl enable kube-proxy

systemctl start etcd
systemctl start docker
systemctl start kube-apiserver
systemctl start kube-controller-manager
systemctl start kube-scheduler
systemctl start kubelet
systemctl start kube-proxy

cat >> /root/.bashrc << EOF
# kubectl alias
alias kc='kubectl'
alias kcg='kubectl get'
alias kcc='kubectl create'
alias kcd='kubectl delete'
EOF
