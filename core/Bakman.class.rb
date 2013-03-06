#!/usr/bin/ruby
require 'yaml'
require 'core/Server.class.rb'

class Bakman
  
  # gets the list of servers
  def self.get_servers
    
    begin
      
      # grab the servers
      server_configs = YAML.load( File.read( "servers.yaml" ) )
    
      # return the servers if they exist
      if server_configs
      
        servers_a = Array.new
      
        server_configs.each do | name, config |
        
          servers_a << Server.new( name, config )
        
        end
      
        return servers_a
      
      end
    
      # tell the user off for not supplying us some servers to backup
      puts "Failed loading servers list, please add a server to the servers.yaml!"
      exit
    
    rescue Exception => e
      
      puts "Failed to load servers list, invalid configuration please remember to use 2 spaces and not tabs!"
      exit
      
    end
    
  end
  
  # runs the backup
  def self.run
    
    puts "Attemping to backup...\n"
    servers = get_servers
        
    if servers
    
      puts "Starting backups...\n"
    
      servers.each do | server |
        
        puts "Backing up #{server.name}\n"
        server.backup
        puts "\n";
      
      end
      
      puts "Finished backing up.\n"
    
    end
    
  end

  
end