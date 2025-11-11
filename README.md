# sorbet-hibp

A simple, clean Ruby wrapper for the Have I Been Pwned API v3.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sorbet-hibp'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install sorbet-hibp
```

## Usage

### Initialize the Client

```ruby
require 'haveibeenpwned'

client = HaveIBeenPwned::Client.new(
  api_key: 'your-api-key-here',
  user_agent: 'MyApp/1.0'
)
```

Get your API key from [haveibeenpwned.com/API/Key](https://haveibeenpwned.com/API/Key).

### Breach Lookups

#### Get all breaches for an account

```ruby
breaches = client.breached_account('test@example.com')
# => [{"Name"=>"Adobe"}, {"Name"=>"LinkedIn"}]

# Get full breach data
breaches = client.breached_account('test@example.com', truncate_response: false)

# Filter by domain
breaches = client.breached_account('test@example.com', domain: 'adobe.com')

# Exclude unverified breaches
breaches = client.breached_account('test@example.com', include_unverified: false)
```

#### Get all breached email addresses for a domain

```ruby
# Requires domain verification in your HIBP dashboard
breached = client.breached_domain('example.com')
# => {"alias1"=>["Adobe"], "alias2"=>["Adobe", "LinkedIn"]}
```

#### Get all breaches in the system

```ruby
all_breaches = client.breaches
# => [{"Name"=>"Adobe", "Title"=>"Adobe", ...}, ...]

# Filter by domain
adobe_breaches = client.breaches(domain: 'adobe.com')

# Filter spam lists
spam_lists = client.breaches(is_spam_list: true)
```

#### Get a single breach

```ruby
breach = client.breach('Adobe')
# => {"Name"=>"Adobe", "Title"=>"Adobe", "Domain"=>"adobe.com", ...}
```

#### Get the latest breach

```ruby
latest = client.latest_breach
# => {"Name"=>"...", "AddedDate"=>"2025-01-15T10:30:00Z", ...}
```

#### Get all data classes

```ruby
classes = client.data_classes
# => ["Account balances", "Email addresses", "Passwords", ...]
```

#### Get subscribed domains

```ruby
domains = client.subscribed_domains
# => [{"DomainName"=>"example.com", "PwnCount"=>150, ...}]
```

### Stealer Logs

Requires Pwned 5+ subscription and verified domain ownership.

#### Get stealer log domains for an email

```ruby
domains = client.stealer_logs_by_email('user@example.com')
# => ["netflix.com", "spotify.com"]
```

#### Get email addresses for a website domain

```ruby
emails = client.stealer_logs_by_website_domain('netflix.com')
# => ["user1@gmail.com", "user2@yahoo.com"]
```

#### Get email aliases for an email domain

```ruby
aliases = client.stealer_logs_by_email_domain('example.com')
# => {"user1"=>["netflix.com"], "user2"=>["spotify.com", "netflix.com"]}
```

### Pastes

```ruby
pastes = client.pastes('test@example.com')
# => [{"Source"=>"Pastebin", "Id"=>"8Q0BvKD8", "Title"=>"syslog", ...}]
```

### Subscription Status

```ruby
status = client.subscription_status
# => {"SubscriptionName"=>"Pwned 3", "Rpm"=>100, ...}
```

### Pwned Passwords

The Pwned Passwords API is completely separate and requires no authentication.

#### Check if a password has been pwned

```ruby
count = HaveIBeenPwned::PwnedPasswords.check('password123')
# => 123456 (number of times this password appears in breaches)

# If password not found
count = HaveIBeenPwned::PwnedPasswords.check('very-unique-password-xyz')
# => 0
```

#### Check with padding (enhanced privacy)

```ruby
count = HaveIBeenPwned::PwnedPasswords.check('password123', padding: true)
```

#### Check a pre-computed hash

```ruby
hash = '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8' # SHA-1 of 'password'
count = HaveIBeenPwned::PwnedPasswords.check_hash(hash)
# => 123456
```

#### Get raw range search results

```ruby
# Get all hash suffixes for a prefix
results = HaveIBeenPwned::PwnedPasswords.range_search('5BAA6')
# => "1E4C9B93F3F0682250B6CF8331B7EE68FD8:123456\n..."
```

## Error Handling

The gem raises specific exceptions for different HTTP errors:

```ruby
begin
  breaches = client.breached_account('test@example.com')
rescue HaveIBeenPwned::NotFoundError
  puts "Account not found in any breaches"
rescue HaveIBeenPwned::UnauthorizedError
  puts "Invalid API key"
rescue HaveIBeenPwned::ForbiddenError
  puts "Missing or invalid user agent"
rescue HaveIBeenPwned::RateLimitError => e
  puts "Rate limit exceeded. Retry after #{e.retry_after} seconds"
rescue HaveIBeenPwned::BadRequestError => e
  puts "Bad request: #{e.message}"
rescue HaveIBeenPwned::ServiceUnavailableError
  puts "Service temporarily unavailable"
rescue HaveIBeenPwned::Error => e
  puts "Unexpected error: #{e.message}"
end
```

## Test Accounts

Use test accounts on `hibp-integration-tests.com` domain with a test API key (any 32-char hex string like `00000000000000000000000000000000`):

```ruby
client = HaveIBeenPwned::Client.new(
  api_key: '00000000000000000000000000000000',
  user_agent: 'Testing'
)

# Test account that exists in breaches
breaches = client.breached_account('account-exists@hibp-integration-tests.com')

# Test account with spam list only
spam = client.breached_account('spam-list-only@hibp-integration-tests.com')

# Test account with stealer logs
logs = client.breached_account('stealer-log@hibp-integration-tests.com')
```

See the [full list of test accounts](https://haveibeenpwned.com/API/v3#TestAccounts) in the API documentation.

## Rate Limiting

Rate limits vary by subscription level. When exceeded, a `RateLimitError` is raised with the `retry_after` attribute indicating seconds to wait:

```ruby
begin
  breaches = client.breached_account('test@example.com')
rescue HaveIBeenPwned::RateLimitError => e
  sleep e.retry_after
  retry
end
```

## Interactive Demo Application

An interactive **Sinatra web application** is included in the `demo/` directory to showcase all features of the gem. The demo provides a beautiful, user-friendly interface to test every API endpoint.

### What's Included

The demo application features:

- **Breach Lookups**: Check if email addresses appear in data breaches
- **Password Checker**: Verify if passwords have been compromised using k-anonymity
- **Pastes Search**: Find if emails appear in public pastes
- **Single Breach Details**: Get comprehensive information about specific breaches
- **All Breaches**: Browse the complete database of breaches
- **Data Classes**: View all types of compromised data
- **Domain Features**: Search breached accounts for verified domains (requires subscription)
- **Stealer Logs**: Check for credentials in stealer logs (requires Pwned 5+ subscription)
- **Subscription Status**: View your API key's subscription tier and rate limits

### Quick Start

Launch the demo with a single command:

```bash
make demo-web
```

This will:
1. Install dependencies (Sinatra, Puma, etc.)
2. Create a configuration file if needed
3. Start the web server on http://localhost:4567

### Manual Setup

If you prefer manual setup:

```bash
# Navigate to demo directory
cd demo

# Install dependencies
bundle install

# Copy configuration template
cp config.yml.example config.yml

# Edit config.yml and add your API key
nano config.yml

# Start the server
bundle exec ruby app.rb
```

Then visit **http://localhost:4567** in your browser.

### Configuration

The demo uses a `config.yml` file with the following parameters:

```yaml
# Your Have I Been Pwned API key
# Get one at: https://haveibeenpwned.com/API/Key
api_key: 'your-api-key-here'

# User agent string (required by HIBP API)
# Format: YourAppName/Version
user_agent: 'HIBP-Ruby-Demo/1.0'
```

#### Configuration Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `api_key` | Yes | Your HIBP API key (32-character hex string) |
| `user_agent` | Yes | Identifier for your application (e.g., "MyApp/1.0") |

#### Using Test Credentials

For testing without a real API key, use these test credentials:

```yaml
api_key: '00000000000000000000000000000000'
user_agent: 'Testing'
```

Then use test email addresses like:
- `account-exists@hibp-integration-tests.com` - Has breaches
- `opt-out@hibp-integration-tests.com` - No breaches (opted out)
- `spam-list-only@hibp-integration-tests.com` - Spam list only

### Available Make Targets

The Makefile provides convenient commands for the demo:

```bash
# Launch the web demo application
make demo-web

# Setup demo (install dependencies, create config)
make demo-web-setup

# Create/recreate configuration file
make demo-web-config
```

### Features by Subscription Tier

Different features require different subscription levels:

**Free Features (No API Key):**
- Pwned Passwords checker

**Pwned 1+ (Requires API Key):**
- Breach account lookups
- All breaches listing
- Single breach details
- Pastes search
- Data classes

**Pwned 2+ Features:**
- Domain breach search
- Subscribed domains list

**Pwned 5+ Features:**
- Stealer logs by email
- Stealer logs by website domain
- Stealer logs by email domain

### Project Structure

```
demo/
├── app.rb                 # Main Sinatra application
├── config.yml             # Your API configuration (gitignored)
├── config.yml.example     # Configuration template
├── Gemfile                # Demo dependencies
├── README.md              # Demo-specific documentation
└── views/                 # ERB templates for each feature
    ├── layout.erb         # Main layout with navigation
    ├── index.erb          # Homepage
    ├── breached_account.erb
    ├── breaches.erb
    ├── breach.erb
    ├── pastes.erb
    ├── pwned_passwords.erb
    └── ... (more templates)
```

### Security Notes

- The `config.yml` file is gitignored to protect your API key
- Never commit real API keys to version control
- The demo loads the gem from local source (`../lib`) for development
- Pwned Passwords uses k-anonymity to protect checked passwords

### Deployment

The demo can be deployed to any Rack-compatible platform:

**Heroku:**
```bash
cd demo
git init
heroku create
git add .
git commit -m "Deploy HIBP demo"
git push heroku master
heroku config:set HIBP_API_KEY=your-key-here
```

**Docker:**
```bash
cd demo
docker build -t hibp-demo .
docker run -p 4567:4567 -e HIBP_API_KEY=your-key hibp-demo
```

For more details, see [demo/README.md](demo/README.md).

## Design Philosophy

This gem follows KISS, DRY, YAGNI, and shibui principles:

- **Simple**: Flat API surface with instance-based configuration
- **Clean**: Returns raw hashes, no unnecessary abstractions
- **Minimal**: Only essential dependencies (Faraday)
- **Clear**: Explicit error handling with semantic exceptions

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

This gem is available as open source under the terms of the [MIT License](LICENSE).

## Attribution

This gem uses the Have I Been Pwned API. Please ensure proper attribution when using this service in your application.

Data sourced from [haveibeenpwned.com](https://haveibeenpwned.com) - check if your email has been compromised in a data breach.
