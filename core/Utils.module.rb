require "yaml"
require "fileutils"
require 'active_support/all'

module Utils
    
  @@y = nil;
  @@moy = nil;
  @@wom = nil;
  @@dom = nil;
  @@dow = nil;
    
  def self.delete_old_file_backups( server )
    month = Utils::get_config_option('months_to_keep_backups').months.ago.month
    filename = "#{Utils::get_config_option('backup_loc')}/#{server.name}/#{Utils::get_config_option('file_backups_folder_name')}/monthly/#{month}.7z"
    FileUtils.rm( filename ) if File.exists?( filename )
  end
  
  def self.delete_old_db_backups( server, db_name )
    month = Utils::get_config_option('months_to_keep_backups').months.ago.month
    filename = "#{Utils::get_config_option('backup_loc')}/#{server.name}/#{Utils::get_config_option('db_backups_folder_name')}/monthly/#{db_name}/#{db_name}_#{month}.sql.gz"
    FileUtils.rm( filename ) if File.exists?( filename )
  end
  
  def self.get_remote_db_filename( db_name )    
    "/tmp/#{db_name}_#{get_dom}.sql.gz"
  end
  
  def self.get_local_db_filename( db_name, server, type ='daily' )
      
    # create the folder if it doesnt exist
    folder = "#{Utils::get_config_option('backup_loc')}/#{server.name}/#{Utils::get_config_option('db_backups_folder_name')}/#{type}/#{db_name}"
    FileUtils.mkdir_p( folder ) unless File.exists?( folder ) && File.directory?( folder )

    case type
    
      when 'daily'
        return "#{folder}/#{db_name}_#{Utils::get_dow}.sql.gz"
      
      when 'weekly'
        return "#{folder}/#{db_name}_week_#{Utils::get_wom}.sql.gz"
        
      when 'monthly'
        return "#{folder}/#{db_name}_#{Utils::get_moy}_#{Utils::get_y}.sql.gz"
    
    end
    
  end

  def self.get_file_backup_filename( server, type = 'weekly' )
    
    folder = "#{Utils::get_config_option('backup_loc')}/#{server.name}/#{Utils::get_config_option('file_backups_folder_name')}/#{type}"
    FileUtils.mkdir_p( folder ) unless File.exists?( folder ) && File.directory?( folder )

    case type
    
      when 'daily'
        return "#{folder}/#{Utils::get_dow}.7z"
      
      when 'weekly'
        return "#{folder}/week_#{Utils::get_wom}.7z"
        
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
  end
  
  def self.get_moy
    @@moy ||= Time.new.month
  end
  
  def self.get_wom
    @@wom ||= ( Time.new.day / 7 ).ceil
  end
    
  def self.get_dom
    @@dom ||= Time.new.day
  end
  
  def self.get_dow
     @@dow ||= Time.new.wday
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
