require_relative 'Utils.module.rb'
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
    
    backup_db if Utils::get_config_option( 'should_backup_databases' )
    backup_files if Utils::get_config_option( 'should_backup_files' )
    
  end
  
  private
  
  def backup_db

    begin    
     
      Net::SSH.start( self.config[ 'ssh_host' ], self.config[ 'ssh_username' ], :password => self.config['ssh_password' ], :port => self.config[ 'ssh_port' ] ) do | ssh |

        # get a list of the databases on the server
        databases = ssh.exec!( "mysql -h '#{self.config[ 'db_host' ]}' -u '#{self.config[ 'db_username' ]}' -p'#{self.config[ 'db_password' ]}' --execute='show databases' | awk '{ print $1 }' | sed 1d" )
        databases = databases.split( /\r?\n/ )

        # loop each db
        databases.each do | db |
          
          # tidy up the db name
          db = db.strip
          
          begin
          
            # get the tables
            tables = ssh.exec!( "mysql -h '#{self.config[ 'db_host' ]}' -u '#{self.config[ 'db_username' ]}' -p'#{self.config[ 'db_password' ]}' --execute='show tables from #{db}' | awk '{ print $1 }' | sed 1d" )
            tables = tables.split( /\r?\n/ )
          
            tables.each do | table |
          
              # get out files names
              local_filename =  Utils::get_local_db_filename( table, db, self )
              remote_filename = Utils::get_remote_db_filename( table, db )
          
              # backup the backup
              weekly_filename = Utils::get_local_db_filename( table, db, self, 'weekly' )
              monthly_filename = Utils::get_local_db_filename( table, db, self, 'monthly' )
          
              # first of month - create a copy
              FileUtils.cp( local_filename, monthly_filename ) if Utils::get_dom == 1
    
              # its a sunday - create a copy
              FileUtils.cp( local_filename, weekly_filename ) if Utils::get_dow == 0
      
              # Delete older backups
              Utils::delete_old_db_backups( self, db, table )
        
              # get mysql to dump the database to file
              ssh.exec!( "mysqldump -h '#{self.config[ 'db_host' ]}' -u '#{self.config[ 'db_username' ]}' -p'#{self.config[ 'db_password' ]}' '#{db}' '#{table}' --single-transaction | gzip  > #{remote_filename}" )
        
              puts "Downloading #{remote_filename} from #{self.config[ 'ssh_host' ]} to #{local_filename}...\n"
        
              begin

                # scp to files to the local dir        
                Net::SCP.start( self.config[ 'ssh_host' ], self.config[ 'ssh_username' ], :password => self.config['ssh_password' ], :port => self.config[ 'ssh_port' ] ) do |scp|

                  # scp to files to the local dir        
                  scp.download!( remote_filename, local_filename )
                  puts "Done.\n\n"

                end

              rescue Exception => e
          
                puts "Failed to get table listings for #{db} from #{self.config[ 'ssh_host' ]} error: #{e} !!\n\n"
          
              end
            
              # remove the file now that we have downloaded it
              ssh.exec!( "rm -rf #{remote_filename}" )
            
            end # end of table each
            
          rescue Exception => e #table begin
      
            puts "Failed to download #{db} from #{self.config[ 'ssh_host' ]}, error: #{e} !!\n\n"
      
          end
          
        end # end of db each
    
      end
    
    rescue Exception => e

      puts "#{e}Failed to connect to #{self.config[ 'ssh_host' ]}"
          
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

    puts "Backing up remote dir: #{self.config[ 'remote_dir' ]} to #{filestore_loc}...\n\n"

    # uses expect + rsync to backup the files
    cmd = "rsync -azL -e 'ssh -p #{self.config[ 'ssh_port' ]} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' #{self.config[ 'ssh_username' ]}@#{self.config[ 'ssh_host' ]}:#{self.config[ 'remote_dir' ]} #{filestore_loc}"

   puts cmd;

    PTY.spawn( cmd ) do | o, i |
            
      begin

        o.expect(/password/i)
        i.puts "#{self.config[ 'ssh_password' ]}\r\n"
        o.readlines

      rescue Exception => e
        puts "Login rsync error: #{e}"
      end
     
    end

    puts "Done.\n"
    puts "Compressing backups...\n\n"
    
    begin
    
      # zip up the files
      puts "7za u #{daily_filename} -uq0 -ms=off #{filestore_loc}/*"
      system( "7za u #{daily_filename} -uq0 -ms=off #{filestore_loc}/*")
      
      # first of month - create a copy
      FileUtils.cp( daily_filename, monthly_filename ) if Utils::get_dom == 1
    
      # its a sunday - create a copy
      FileUtils.cp( daily_filename, weekly_filename ) if Utils::get_dow == 0
      
      # Delete older backups
      Utils::delete_old_file_backups
      
      puts "Done.\n"
    
    rescue Exception => e
      
      puts "Failed to compress you might not have installed 7zip. More details: #{e}\n\n";
      puts "OSX: brew install p7zip\n"
      puts "YUM: yum install p7zip\n"
      puts "APT: apt-get install p7zip\n"

    end
    
  end
  
end
