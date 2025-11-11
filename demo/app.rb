require 'sinatra'
require 'sinatra/json'
require 'yaml'
require_relative '../lib/haveibeenpwned'

# Load configuration
config_file = File.join(__dir__, 'config.yml')
unless File.exist?(config_file)
  puts "⚠️  config.yml not found. Copy config.yml.example to config.yml and add your API key."
  exit 1
end

CONFIG = YAML.load_file(config_file)

# Initialize the HIBP client
configure do
  set :client, HaveIBeenPwned::Client.new(
    api_key: CONFIG['api_key'],
    user_agent: CONFIG['user_agent']
  )
end

# Home page
get '/' do
  erb :index
end

# Breached Account Lookup
get '/breached-account' do
  erb :breached_account
end

post '/breached-account' do
  email = params[:email]
  options = {}
  options[:truncate_response] = params[:truncate] == 'true'
  options[:domain] = params[:domain] unless params[:domain].to_s.empty?
  options[:include_unverified] = params[:include_unverified] == 'true'

  begin
    @result = settings.client.breached_account(email, **options)
    @email = email
    @success = true
  rescue HaveIBeenPwned::NotFoundError
    @result = []
    @email = email
    @success = true
    @message = "No breaches found for this account"
  rescue HaveIBeenPwned::Error => e
    @error = "Error: #{e.class.name} - #{e.message}"
  end

  erb :breached_account
end

# All Breaches
get '/breaches' do
  erb :breaches
end

post '/breaches' do
  options = {}
  options[:domain] = params[:domain] unless params[:domain].to_s.empty?
  options[:is_spam_list] = params[:spam_list] == 'true' if params[:spam_list]

  begin
    @result = settings.client.breaches(**options)
    @success = true
  rescue HaveIBeenPwned::Error => e
    @error = "Error: #{e.class.name} - #{e.message}"
  end

  erb :breaches
end

# Single Breach
get '/breach' do
  erb :breach
end

post '/breach' do
  breach_name = params[:breach_name]

  begin
    @result = settings.client.breach(breach_name)
    @breach_name = breach_name
    @success = true
  rescue HaveIBeenPwned::NotFoundError
    @error = "Breach '#{breach_name}' not found"
  rescue HaveIBeenPwned::Error => e
    @error = "Error: #{e.class.name} - #{e.message}"
  end

  erb :breach
end

# Latest Breach
get '/latest-breach' do
  begin
    @result = settings.client.latest_breach
    @success = true
  rescue HaveIBeenPwned::Error => e
    @error = "Error: #{e.class.name} - #{e.message}"
  end

  erb :latest_breach
end

# Data Classes
get '/data-classes' do
  begin
    @result = settings.client.data_classes
    @success = true
  rescue HaveIBeenPwned::Error => e
    @error = "Error: #{e.class.name} - #{e.message}"
  end

  erb :data_classes
end

# Pastes
get '/pastes' do
  erb :pastes
end

post '/pastes' do
  email = params[:email]

  begin
    @result = settings.client.pastes(email)
    @email = email
    @success = true
  rescue HaveIBeenPwned::NotFoundError
    @result = []
    @email = email
    @success = true
    @message = "No pastes found for this account"
  rescue HaveIBeenPwned::Error => e
    @error = "Error: #{e.class.name} - #{e.message}"
  end

  erb :pastes
end

# Breached Domain
get '/breached-domain' do
  erb :breached_domain
end

post '/breached-domain' do
  domain = params[:domain]

  begin
    @result = settings.client.breached_domain(domain)
    @domain = domain
    @success = true
  rescue HaveIBeenPwned::Error => e
    @error = "Error: #{e.class.name} - #{e.message}"
  end

  erb :breached_domain
end

# Subscribed Domains
get '/subscribed-domains' do
  begin
    @result = settings.client.subscribed_domains
    @success = true
  rescue HaveIBeenPwned::Error => e
    @error = "Error: #{e.class.name} - #{e.message}"
  end

  erb :subscribed_domains
end

# Subscription Status
get '/subscription-status' do
  begin
    @result = settings.client.subscription_status
    @success = true
  rescue HaveIBeenPwned::Error => e
    @error = "Error: #{e.class.name} - #{e.message}"
  end

  erb :subscription_status
end

# Stealer Logs - By Email
get '/stealer-logs-email' do
  erb :stealer_logs_email
end

post '/stealer-logs-email' do
  email = params[:email]

  begin
    @result = settings.client.stealer_logs_by_email(email)
    @email = email
    @success = true
  rescue HaveIBeenPwned::Error => e
    @error = "Error: #{e.class.name} - #{e.message}"
  end

  erb :stealer_logs_email
end

# Stealer Logs - By Website Domain
get '/stealer-logs-website' do
  erb :stealer_logs_website
end

post '/stealer-logs-website' do
  domain = params[:domain]

  begin
    @result = settings.client.stealer_logs_by_website_domain(domain)
    @domain = domain
    @success = true
  rescue HaveIBeenPwned::Error => e
    @error = "Error: #{e.class.name} - #{e.message}"
  end

  erb :stealer_logs_website
end

# Stealer Logs - By Email Domain
get '/stealer-logs-domain' do
  erb :stealer_logs_domain
end

post '/stealer-logs-domain' do
  domain = params[:domain]

  begin
    @result = settings.client.stealer_logs_by_email_domain(domain)
    @domain = domain
    @success = true
  rescue HaveIBeenPwned::Error => e
    @error = "Error: #{e.class.name} - #{e.message}"
  end

  erb :stealer_logs_domain
end

# Pwned Passwords
get '/pwned-passwords' do
  erb :pwned_passwords
end

post '/pwned-passwords' do
  password = params[:password]
  use_padding = params[:padding] == 'true'

  begin
    @count = HaveIBeenPwned::PwnedPasswords.check(password, padding: use_padding)
    @password_safe = @count == 0
    @success = true
  rescue HaveIBeenPwned::Error => e
    @error = "Error: #{e.class.name} - #{e.message}"
  end

  erb :pwned_passwords
end

# API endpoint for JSON responses
get '/api/check-password/:password' do
  content_type :json
  password = params[:password]

  begin
    count = HaveIBeenPwned::PwnedPasswords.check(password)
    json safe: count == 0, count: count
  rescue HaveIBeenPwned::Error => e
    status 500
    json error: e.message
  end
end
