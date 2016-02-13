#! /usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'right_api_client'
require 'client'
require 'print_cloud_hrefs'
require 'optparse'
require 'yaml'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

  opts.on('-e',
          '--email EMAIL_ADDRESS', 'Email Address') { |v| options[:email] = v }

  opts.on('-p',
          '--password PASSWORD', 'Password') { |v| options[:password] = v }

  opts.on('-a',
          '--account ID', 'Account ID') { |v| options[:account_id] = v }

  opts.on('-r',
          '--refresh REFRESH_TOKEN',
          'Refresh token') { |v| options[:refresh_token] = v }

  opts.on('-u',
          '--url API_URL',
          'Host to connect to') { |v| options[:host] = v }

  opts.on('-i',
          '--include_images',
          'Include image hrefs (can be many)') { |v| options[:images] = v }

  opts.on('-h',
          '--help', 'Display this screen') do
            puts opts
            exit
          end
end.parse!

@client = login(options)
@deployment_id = options[:deployment_id]

print_cloud_details @client, options[:images]
