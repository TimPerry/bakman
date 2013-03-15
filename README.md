#BAKMAN - Ruby website backup system

Uses rsync and mysql to backup files via ssh. 

example servers.yaml server config

example.website.com:
  ssh_username: root
  ssh_password: password
  ssh_port: 22
  ssh_host: localhost
  remote_dir: /var/www/
  db_username: username
  db_password: password

