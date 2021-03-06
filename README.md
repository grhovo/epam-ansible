Ansible-playbook to create wordpress site
To run playbook, add your host in hosts file and make sure you've keys for connection
To run playbook, use
ansible-playbook -i hosts playbook.yaml --extra-vars "ansible_sudo_pass=yoursudopassword"
