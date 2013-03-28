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

  # run the backup whilst using the pid file
  PidFile.new( :piddir => File.dirname( __FILE__ ), :pidfile => "bakman.pid" )
  Bakman.run

rescue Exception => e
  
  puts "#{e}"
  
end