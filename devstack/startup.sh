#!/bin/bash

su stack
cd ~/devstack
./unstack.sh
./stack.sh
