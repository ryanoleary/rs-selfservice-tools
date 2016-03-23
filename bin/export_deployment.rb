#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'right_api_client'
require 'client'
require 'deployment_cat'
require 'optparse'
require 'yaml'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

  opts.on('-d',
          '--deployment ID',
          'Deployment ID') do |v|
            options[:deployment_id] = v
          end

  opts.on('-e',
          '--email EMAIL_ADDRESS',
          'Email Address') do |v|
            options[:email] = v
          end

  opts.on('-p',
          '--password PASSWORD',
          'Password') do |v|
            options[:password] = v
          end

  opts.on('-a',
          '--account ID', 'Account ID') do |v|
            options[:account_id] = v
          end

  opts.on('-r',
          '--refresh REFRESH_TOKEN',
          'Refresh token') do |v|
            options[:refresh_token] = v
          end

  opts.on('-u',
          '--url API_URL',
          'Host to connect to') do |v|
            options[:host] = v
          end

  opts.on('-i',
          '--deployment_inputs',
          'Set inputs at the deployment level') do |v|
            options[:deployment_inputs] = v
          end

  opts.on('-c',
          '--concurrent_launch',
          'Set the resources to launch concurrently') do |v|
            options[:concurrent_launch] = v
          end

  opts.on('-h',
          '--help', 'Display this screen') do
            puts opts
            exit
          end
end.parse!

@client = login(options)

deployment_to_cat_file @client,
                       options[:deployment_id],
                       options[:deployment_inputs],
                       options[:concurrent_launch]
