#!/bin/bash

# 针对不同的node进行不同的provision，通过参数$1传递

function node1_provision() {
  echo "Provision node1 ..."
}
function node2_provision() {
  echo "Provision node2 ..."
}
function node3_provision() {
  echo "Provision node3 ..."
}

if [ $1 = "node1" ]; then
  node1_provision
elif [ $1 = "node2" ]; then
  node2_provision
elif [ $1 = "node3" ]; then
  node3_provision
else
  echo "Provision others..."
fi
