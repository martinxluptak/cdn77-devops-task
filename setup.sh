#!/bin/bash

ansible-playbook -i 'nginx-1,' nginx-playbook.yml  -c docker
ansible-playbook -i 'nginx-2,' cache-playbook.yml  -c docker
