#!/usr/bin/ruby
require 'rubygems'
require 'lib/pidfile.class.rb'
require 'core/Bakman.class.rb'

# run the backup whilst using the pid file
PidFile.new( :piddir => File.dirname( __FILE__ ), :pidfile => "bakman.pid" )
Bakman.run
exit