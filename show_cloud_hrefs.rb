require "rubygems"
require "right_api_client"
require File.expand_path('../lib/print_cloud_hrefs', __FILE__)



require "optparse"
require "yaml"

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: export_deployment [options]"

  opts.on("-e", "--email EMAIL_ADDRESS", "Email Address") { |v| options[:email] = v }
  opts.on("-p", "--password PASSWORD", "Password") { |v| options[:password] = v }
  opts.on("-a", "--account ID", "Account ID") { |v| options[:account_id] = v }

  opts.on( "-h:", "--help", "Display this screen" ) do
     puts opts
     exit
  end

end.parse!

# Login to RightScale
@client = RightApi::Client.new(:email=>options[:email],:password=>options[:password],:account_id=>options[:account_id])

print_cloud_details @client
