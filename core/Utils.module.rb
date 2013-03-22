require "yaml"
require "fileutils"

module Utils
    
  @@y = nil;
  @@moy = nil;
  @@wom = nil;
  @@dom = nil;
  @@dow = nil;
    
  def self.get_remote_db_filename( db_name )    
    "/tmp/#{db_name}_#{get_dom}.sql.gz"
  end
  
  def self.get_local_db_filename( db_name, server )
    
    # create the folder if it doesnt exist
    folder = "#{Utils::get_config_option('backup_loc')}/#{server.name}/#{Utils::get_config_option('db_backups_folder_name')}/#{db_name}"
    FileUtils.mkdir_p(folder) unless File.exists?(folder) && File.directory?(folder)
        
    "#{folder}/#{db_name}_#{get_dom}.sql.gz".strip
    
  end

  def self.get_file_backup_filename( server, type = 'weekly' )
    
    folder = "#{Utils::get_config_option('backup_loc')}/#{server.name}/#{Utils::get_config_option('file_backups_folder_name')}/#{type}"
    FileUtils.mkdir_p( folder ) unless File.exists?( folder ) && File.directory?( folder )

    case type
    
      when 'daily'
        return "#{folder}/#{Utils::get_dow}.7z"
      
      when 'weekly'
        return "#{folder}/week#{Utils::get_wom}.7z"
        
      when 'monthly'
        return "#{folder}/#{Utils::get_moy}_#{Utils::get_y}.7z"
    
    end
    
  end
  
  def self.get_filestore_loc( server )
    
    folder = "#{Utils::get_config_option('backup_loc')}/#{server.name}/#{Utils::get_config_option('file_backups_folder_name')}/filestore"
    FileUtils.mkdir_p( folder ) unless File.exists?( folder ) && File.directory?( folder )
    
    folder.strip
    
  end
    
  def self.delete_oldest_backup( server )
   
    month = Time.now.months_since( -6 ).month
    FileUtils.rm( "#{Utils::get_config_option('backup_loc')}/#{server.name}/#{Utils::get_config_option('db_backups_folder_name')}/#{month}.7z" )
    
  end

  def self.get_y
    @@y ||= Time.new.year
    @@y
  end
  
  def self.get_moy
    @@moy ||= Time.new.month
    @@moy
  end
  
  def self.get_wom
    @@wom ||= ( Time.new.day / 7 ).ceil
    @@wom
  end
    
  def self.get_dom
    @@dom ||= Time.new.day
    @@dom
  end
  
  def self.get_dow
     @@dow ||= Time.new.wday
     @@dow
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