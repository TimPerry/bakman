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

    date = Utils::get_config_option('months_to_keep_backups').months.ago
    month = Date::MONTHNAMES[ date.month ].downcase
    year = date.year
    
    filename = "#{Utils::get_config_option('backup_loc')}/#{server.name}/#{Utils::get_config_option('file_backups_folder_name')}/monthly/#{month}_#{year}.7z"

    if File.exists?( filename )
      puts "Deleting old backup #{filename}"
      FileUtils.rm( filename )
    end

  end
  
  def self.delete_old_db_backups( server, db_name, table_name )
    
    date = Utils::get_config_option('months_to_keep_backups').months.ago
    month = Date::MONTHNAMES[ date.month ].downcase
    year = date.year
    
    filename = "#{Utils::get_config_option('backup_loc')}/#{server.name}/#{Utils::get_config_option('db_backups_folder_name')}/monthly/#{month}_#{year}/#{db_name}/#{table_name}.sql.gz"

    if File.exists?( filename )
      puts "Deleting old backup #{filename}"
      FileUtils.rm( filename )
    end

  end
  
  def self.get_remote_db_filename( table_name, db_name )    
    "/tmp/#{db_name}_#{table_name}.sql.gz"
  end
  
  def self.get_local_db_filename( table_name, db_name, server, type = 'daily' )

    folder = "#{Utils::get_config_option('backup_loc')}/#{server.name}/#{Utils::get_config_option('db_backups_folder_name')}/#{type}"

    case type
    
      when 'daily'
        folder << "/#{Utils::get_nice_dow}/#{db_name}"
        
      when 'weekly'
        folder << "/week_#{Utils::get_wom}/#{db_name}"
                
      when 'monthly'
        folder << "/#{Utils::get_nice_moy}_#{Utils::get_y}/#{db_name}"
    
    end
      
    # create the folder if it doesnt exist
    FileUtils.mkdir_p( folder ) unless File.exists?( folder ) && File.directory?( folder )
    
    # return the full path
    "#{folder}/#{table_name}.sql.gz"
    
  end

  def self.get_file_backup_filename( server, type = 'weekly' )
    
    folder = "#{Utils::get_config_option('backup_loc')}/#{server.name}/#{Utils::get_config_option('file_backups_folder_name')}/#{type}"
    FileUtils.mkdir_p( folder ) unless File.exists?( folder ) && File.directory?( folder )

    case type
    
      when 'daily'
        return "#{folder}/#{Utils::get_nice_dow}.7z"
      
      when 'weekly'
        return "#{folder}/week_#{Utils::get_wom}.7z"
        
      when 'monthly'
        return "#{folder}/#{Utils::get_nice_moy}_#{Utils::get_y}.7z"
    
    end
    
  end
  
  def self.get_filestore_loc( server )
    
    folder = "#{Utils::get_config_option('backup_loc')}/#{server.name}/#{Utils::get_config_option('file_backups_folder_name')}/#{Utils::get_config_option('file_backups_cache_directory_name')}"
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
  
  def self.get_nice_moy
    Date::MONTHNAMES[ Utils::get_moy.to_i ].downcase
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
  
  def self.get_nice_dow
    Date::DAYNAMES[ Utils::get_dow.to_i ].downcase
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
      puts "Failed to load config file config.yaml, invalid configuration please remember to use 2 spaces and not tabs!"
      exit
    end
  end
  
end
