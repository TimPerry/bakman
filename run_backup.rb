#!/usr/bin/ruby
require 'rubygems'
require_relative 'lib/pidfile.class.rb'
require_relative 'core/Bakman.class.rb'

# run the backup whilst using the pid file
PidFile.new( :piddir => File.dirname( __FILE__ ), :pidfile => "bakman.pid" )
Bakman.run
exec("chmod -R 777 /backups");
exit
