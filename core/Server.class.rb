require 'core/Utils.module.rb'
require 'net/ssh'
require 'net/scp'

class Server
  
  attr_accessor :config, :name
  
  include Utils
  
  def initialize( name, config )
      
    # store the config for the server  
    self.name = name
    self.config = config
    
  end
    
  def backup
    
    backup_db
    backup_files
    
  end
  
  private
  
  def backup_db
    
    begin
      
      Net::SSH.start( self.config[ 'ssh_host' ], self.config[ 'ssh_username' ], :password => self.config['ssh_password' ] ) do | ssh |
        
        # get a list of the databases on the server
        databases = ssh.exec!( "mysql -u #{self.config[ 'db_username' ]} -p#{self.config[ 'db_password' ]} --execute='show databases' | awk '{ print $1 }' | sed 1d" )       
          
        # loop each db
        databases.each do | db |
          
          # tidy up the db name
          db = db.strip
          
          # get out files names
          local_filename =  Utils::get_local_db_filename( db, self )
          remote_filename = Utils::get_remote_db_filename( db )
        
          # get mysql to dump the database to file
          ssh.exec!( "mysqldump -u #{self.config[ 'db_username' ]} -p#{self.config[ 'db_password' ]} #{db} --single-transaction | gzip  > #{remote_filename}" )
        
          puts "Downloading #{remote_filename} from #{self.config[ 'ssh_host' ]} to #{local_filename}...\n"
        
          begin

            # scp to files to the local dir        
            Net::SCP.start( self.config[ 'ssh_host' ], self.config[ 'ssh_username' ], :password => self.config['ssh_password' ] ) do |scp|

              # scp to files to the local dir        
              scp.download!( remote_filename, local_filename )
              puts "Done.\n\n"

            end

          rescue Exception => e
          
            puts "!! Failed to download #{db} from #{self.config[ 'ssh_host' ]} !!\n\n"
          
          end
          
          # remove the file now that we have downloaded it
          ssh.exec!( "rm -rf #{remote_filename}" )
      
        end
    
      end
    
    rescue Exception => e
          
      puts "Failed to connect to #{self.config[ 'ssh_host' ]}"
          
    end
  
  end

  def backup_files
  
    # backup the backup
    #filename=${folders[1]}/${dow}.7z
    #backup_loc=${folders[2]}
    
    # remove the old zip
    #rm -rf $filename
    #7za a -t7z $filename $backup_loc/*

    # backup them files!
    #rsync -az --delete -e "ssh -p $server_port" root@${server_ip}:${server_path} $backup_loc
    
    # if its the first of the month copy the zip ( dom == 1)
    # cp filename begin_of_month.7z
    
    # if its a monday copy ( dow == 1 )
    
    # folder structure
    #
    # monthly
    #   jan_2013.7z
    #   feb_2013.7z
    #
    # weekly
    #   first_week_of_month.7z
    #   second_week_of_month.7z
    #   third_week_of_month.7z
    #   four_week_of_month.7z
    #   fith_week_of_month.7z90
    #
    # daily
    #   monday.7z
    #   tuesday.7z
    #   wednesday.7z
    #   thursday.7z
    #   friday.7z
    #   saturday.7z
    #   sunday.7z
    
  end
  
end