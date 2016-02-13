def login(options)
  if options[:host]
    api_url = options[:host]
  else
    api_url = 'https://us-3.rightscale.com'
  end

  # login to RightScale
  if options[:email] && options[:password]
    @client = RightApi::Client.new(email: options[:email],
                                   password: options[:password],
                                   account_id: options[:account_id],
                                   api_url: api_url
                                  )
  elsif options[:refresh_token]
    @client = RightApi::Client.new(refresh_token: options[:refresh_token],
                                   account_id: options[:account_id],
                                   api_url: api_url
                                  )
  else
    puts 'You must provide either email/password or refresh token'
    exit(1)
  end
end
