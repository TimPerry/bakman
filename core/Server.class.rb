require 'core/Utils.module.rb'
require 'net/ssh'
require 'net/scp'
require 'pty'
require 'expect'

class Server
  
  attr_accessor :config, :name
  
  include Utils
  
  def initialize( name, config )
      
    # store the config for the server  
    self.name = name
    self.config = config
    
  end
    
  def backup
    
    backup_db if Utils::get_config_option( 'should_backup_backups' )
    backup_files if Utils::get_config_option( 'should_backup_files' )
    
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
    daily_filename = Utils::get_file_backup_filename( self, 'daily' )
    weekly_filename = Utils::get_file_backup_filename( self, 'weekly' )
    monthly_filename = Utils::get_file_backup_filename( self, 'monthly' )
    
    # backup location
    filestore_loc = Utils::get_filestore_loc( self )
    
    # remove the old zip
    FileUtils.rm( daily_filename ) if File.exists?( daily_filename )

    # uses expect + rsync to backup the files
    cmd = "rsync -az --delete -e 'ssh -p #{self.config[ 'ssh_port' ]} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' #{self.config[ 'ssh_username' ]}@#{self.config[ 'ssh_host' ]}:#{self.config[ 'remote_dir' ]} #{filestore_loc}"
      
    PTY.spawn( cmd ) do | o, i |
            
      o.expect(/Password/, 2)
      i.puts "#{self.config[ 'ssh_password' ]}\r\n"
      o.readlines      
     
    end
    
    # zip up the files
    system "7za a -t7z #{daily_filename} #{filestore_loc}/*"
      
    # first of month - create a copy
    FileUtils.cp( daily_filename, monthly_filename ) if Utils::get_dom == 1
    
    # its a sunday - create a copy
    FileUtils.cp( daily_filename, weekly_filename ) if Utils::get_dow == 0
    
  end
  
end