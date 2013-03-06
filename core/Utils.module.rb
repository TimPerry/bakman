require "yaml"
require "fileutils"

module Utils
  
  def self.get_remote_db_filename( db_name )    
    "/tmp/#{db_name}_#{get_dom}.sql.gz"
  end
  
  def self.get_local_db_filename( db_name, server )
    
    # create the folder if it doesnt exist
    folder = "#{Utils::get_config_option('backup_loc')}/#{server.name}/#{Utils::get_config_option('db_backups_folder_name')}/#{db_name}"
    FileUtils.mkdir_p(folder) unless File.exists?(folder) && File.directory?(folder)
        
    "#{folder}/#{db_name}_#{get_dom}.sql.gz".strip
    
  end
    
  def self.delete_oldest_backup( server_name )
    month = Time.now.months_since( -6 ).
    FileUtils.rm( "#{Utils::get_config_option('backup_loc')}/#{server.name}/#{Utils::get_config_option('db_backups_folder_name')}/#{month}.7z" )
  end
    
  def self.get_dom
    Time.new.day
  end
  
  def self.get_dow
     Time.new.wday
  end
  
  # gets the config option if it exists
  def self.get_config_option( option )
    
    # grab the config from file if its not already loaded
    config = get_config

    # return the option if it exists
    return config[ option ] if config[ option ]
  
  end
  
  private
    
  # gets the main config
  def self.get_config
    
    begin
      
      YAML.load( File.read( "config.yaml" ) )

    rescue Exception => e
      
      puts "Failed to load config file, invalid configuration please remember to use 2 spaces and not tabs!"
      exit
      
    end
    
  end
  
end