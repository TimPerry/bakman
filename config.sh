# SETTINGS #
# FORMAT <FOLDER_NAME>|<SERVER_IP>|<SERVER_PORT>|<WEB_DIR>

servers[0]='Server_Name|192.168.1.250|22|/var/www/'

# CONSTANTS
savedIFS=$IFS
dow="$(date +'%A')"
dom="$(date +'%d')"
moy="$(date +'%m')"
root_backup_loc="/backups"
db_user='username'
db_pass='password'
