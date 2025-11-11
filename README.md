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
