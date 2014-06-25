#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'pp'
require File.expand_path('../lib/convert_cft_to_cat.rb', __FILE__)


require "optparse"

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: export_deployment [options]"

  opts.on("-f", "--file FILE_NAME", "Filename of the CFT file") { |v| options[:filename] = v }

  opts.on( "-h", "--help", "Display this screen" ) do
     puts opts
     exit
  end

end.parse!

json = File.read(options[:filename])
output_file = options[:filename] + ".cat.rb"
cat_name = File.basename options[:filename], ".*"

convert_cft_to_cat json, output_file, cat_name


