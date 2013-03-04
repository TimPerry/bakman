#! /bin/bash

# WARNING - PURE AWESOMENESS FOLLOWS THIS NOTICE #

# INCLUDE THE CONFIG #
source /backups/config.sh

# PID FILE FOR NON ATMOIC RUNNING OF SCRIPT #
pid_file=/backups/backup_script.pid

if [ -f "$pid_file" ] && kill -0 `cat $pid_file` 2>/dev/null; then
    echo "ERROR: A backup is still runing"
    exit 1
fi 
echo $$ > $pid_file

if [ ! -d $root_backup_loc ];
then
	mkdir $root_backup_loc
fi
chmod 777 $root_backup_loc

for server in "${servers[@]}"
do

	# use ifs to set the splitter, then call set to create an array
	IFS="|"
	set -- $server
	server_name=$1
	server_ip=$2
	server_port=$3
	server_path=$4
	IFS=$savedIFS

	# check if our file structure is correct
	folders[0]=${root_backup_loc}/${server_name}_Backups
	folders[1]=${root_backup_loc}/${server_name}_Backups/Website_Backups
	folders[2]=${root_backup_loc}/${server_name}_Backups/Website_Files
	folders[3]=${root_backup_loc}/${server_name}_Backups/DB_Files

	# create the file structure ( if needed ) and sort out the perms
	for folder in "${folders[@]}"
	do
		if [ ! -d $folder ]; 
		then
			mkdir $folder
		fi	
		chmod -R 777 $folder
	done

	# get a list of databases on the current server
	databases=`ssh root@$server_ip -p $server_port "mysql -u $db_user -p$db_pass --execute='show databases' " | awk '{ print $1 }' `

	IFS=$savedIFS
				
	# backup the databases
	for db in $databases
	do
		if [ $db != "Database" ]
		then		
			filename_db="${db}_${dom}.sql.gz"
			filename_db_local="${folders[3]}/${db}_${dom}.sql.gz"
			ssh root@$server_ip -p $server_port "mysqldump -u $db_user -p$db_pass $db --single-transaction | gzip  > $filename_db"
			scp -P $server_port $server_ip:~/$filename_db $filename_db_local
			#ssh root@$server_ip -p $server_port "rm - rf $filename_db"
		fi
	done

	# backup the backup
        filename=${folders[1]}/${dow}.7z
        backup_loc=${folders[2]}

        # remove the old zip
        rm -rf $filename
        7za a -t7z $filename $backup_loc/*

	# backup them files!
        rsync -az --delete -e "ssh -p $server_port" root@${server_ip}:${server_path} $backup_loc

done

rm $pid_file
exit
