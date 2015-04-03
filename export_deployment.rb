require "rubygems"
require "right_api_client"
require File.expand_path('../lib/deployment_cat', __FILE__)

require "optparse"
require "yaml"

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: export_deployment [options]"

  opts.on("-d", "--deployment ID", "Deployment ID") { |v| options[:deployment_id] = v }
  opts.on("-e", "--email EMAIL_ADDRESS", "Email Address") { |v| options[:email] = v }
  opts.on("-p", "--password PASSWORD", "Password") { |v| options[:password] = v }
  opts.on("-a", "--account ID", "Account ID") { |v| options[:account_id] = v }
  opts.on("-r", "--refresh REFRESH_TOKEN", "Refresh token") { |v| options[:refresh_token] = v }
  opts.on("-i", "--deployment_inputs", "Set inputs at the deployment level" ) { |v| options[:deployment_inputs] = v }  
  opts.on("-c", "--concurrent_launch", "Set the resources to launch concurrently" ) { |v| options[:concurrent_launch] = v }  

  opts.on( "-h", "--help", "Display this screen" ) do
     puts opts
     exit
  end

end.parse!

# Login to RightScale
@deployment_id = options[:deployment_id]
if options[:email] && options[:password]
  @client = RightApi::Client.new(:email=>options[:email],:password=>options[:password],:account_id=>options[:account_id])
elsif options[:refresh_token]
  @client = RightApi::Client.new(:refresh_token=>options[:refresh_token],:account_id=>options[:account_id])
else
  puts "You must provide either email/password or refresh token"
  exit(1)
end

deployment_to_cat_file @client, @deployment_id, options[:deployment_inputs], options[:concurrent_launch]
