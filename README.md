# BAKMAN - Ruby website backup system
Backman is a website backup tool written in ruby. It can backup remote mysql servers as well your files.

## Usage

Use the docker image from dockerhub:
```
docker run --rm --interactive --tty --volume backups:/backups --volume config.yaml:/bakman/config.yaml --volume servers.yaml:/backman/servers.yaml timkinbokeh/bakman
```

An example config.yaml file:
```
should_backup_databases: true
should_backup_files: true
months_to_keep_backups: 3
backup_loc: backups
db_backups_folder_name: db
file_backups_folder_name: files
file_backups_cache_directory_name: tmp
```

and an example servers.yaml file:
```
some_server_name:
  ssh_username: bakman
  ssh_password: password
  ssh_port: 22
  ssh_host: 123.123.123.123
  remote_dir: /var/www/
  db_username: bakman
  db_password: password
```
