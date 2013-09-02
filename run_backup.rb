#!/usr/bin/env ruby

abort( "Bakman only runs on ruby 1.9+, please update Ruby" ) unless RUBY_VERSION >= '1.9'

# abort unless all the dependencies are installed
begin

  require 'rubygems'
  require_relative 'lib/pidfile.class.rb'
  require_relative 'core/Bakman.class.rb'
  gem 'net-ssh'
  gem 'net-scp'
  gem 'activesupport'

rescue Exception => e

  abort( "Dependencies not installed please run the install script.\nSimply run ./INSTALL" )

end

begin

  # kill backups if still running
  if File.exists?( "./bakman.pid" )  

    Process.kill( 15, File.read( './bakman.pid' ).to_i ) 
    File.delete( "./bakman.pid" );

  end

  # grab a pidfile
  PidFile.new( :piddir => File.dirname( __FILE__ ), :pidfile => "bakman.pid" )

  # run the backup whilst using the pid file
  Bakman.run

rescue Exception => e

  puts "#{e}"

end
