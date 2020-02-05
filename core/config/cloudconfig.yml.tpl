#cloud-config

package_upgrade: true

packages:
   - docker.io
   - ntp

users:
  - default
  - name: deployman
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - ssh-rsa AAAAB3<snip>

runcmd:
 - sudo usermod -aG docker deployman
 - sudo systemctl enable docker
 - sudo systemctl restart docker