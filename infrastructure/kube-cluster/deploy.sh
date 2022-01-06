#!/bin/bash

set -xe

ansible-playbook -i hosts initial.yml
ansible-playbook -i hosts kube-dependencies.yml
ansible-playbook -i hosts master.yml
ansible-playbook -i hosts workers.yml
