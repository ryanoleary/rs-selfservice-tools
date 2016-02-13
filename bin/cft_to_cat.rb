#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'json'
require 'pp'
require 'convert_cft_to_cat'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

  opts.on('-f',
          '--file FILE_NAME',
          'Filename of the CFT file') { |v| options[:filename] = v }

  opts.on('-h',
          '--help', 'Display this screen') do
    puts opts
    exit
  end
end.parse!

json = File.read(options[:filename])
output_file = options[:filename] + '.cat.rb'
cat_name = File.basename options[:filename], '.*'

convert_cft_to_cat json, output_file, cat_name
