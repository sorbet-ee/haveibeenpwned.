# HaveIBeenPwned Ruby Gem - Demo Application

An interactive Sinatra web application demonstrating all features of the **sorbet-hibp** Ruby gem.

## Features

This demo app showcases all functionality of the HaveIBeenPwned API wrapper:

### ✅ Implemented Features

- **Breach Lookups**
  - Check if an email has been breached
  - View all breaches in the system
  - Get details of a specific breach
  - View the latest breach
  - Browse data classes

- **Pastes**
  - Search for emails in public pastes

- **Pwned Passwords**
  - Check if passwords have been compromised
  - Uses k-anonymity for privacy

- **Domain Features** (requires subscription)
  - Search breached accounts for your domain
  - View subscribed domains
  - Search stealer logs by email, website, or domain

- **Account Management**
  - View subscription status and rate limits

## Prerequisites

- Ruby 3.0 or higher
- Bundler
- A Have I Been Pwned API key (get one at [haveibeenpwned.com/API/Key](https://haveibeenpwned.com/API/Key))

## Setup

### 1. Install Dependencies

From the `demo` directory:

```bash
cd demo
bundle install
```

### 2. Configure API Key

Copy the example configuration file:

```bash
cp config.yml.example config.yml
```

Edit `config.yml` and add your API key:

```yaml
api_key: 'your-actual-api-key-here'
user_agent: 'HIBP-Ruby-Demo/1.0'
```

### 3. Using Test Credentials

For testing without a real API key, use these test credentials in `config.yml`:

```yaml
api_key: '00000000000000000000000000000000'
user_agent: 'Testing'
```

Then use test email addresses like:
- `account-exists@hibp-integration-tests.com`
- `spam-list-only@hibp-integration-tests.com`
- `opt-out@hibp-integration-tests.com`

See the [full list of test accounts](https://haveibeenpwned.com/API/v3#TestAccounts) in the HIBP API documentation.

## Running the App

Start the Sinatra server:

```bash
bundle exec ruby app.rb
```

Or with automatic reloading during development:

```bash
bundle exec rerun ruby app.rb
```

The application will be available at: **http://localhost:4567**

## Usage

### Home Page

Visit `http://localhost:4567` to see:
- Overview of all features
- Quick start guide
- Links to all demo pages

### Available Endpoints

#### Public Features (No API Key Required)

- **GET/POST /pwned-passwords** - Check if passwords have been compromised

#### API Key Required Features

- **GET/POST /breached-account** - Check if an email has been breached
- **GET/POST /breaches** - View all breaches
- **GET/POST /breach** - Get a specific breach
- **GET /latest-breach** - View the latest breach
- **GET /data-classes** - Browse data classes
- **GET/POST /pastes** - Search email in pastes
- **GET /subscription-status** - View your subscription details

#### Domain Features (Requires Pwned 2+ Subscription)

- **GET/POST /breached-domain** - Search breached accounts for your domain
- **GET /subscribed-domains** - View your subscribed domains

#### Stealer Logs (Requires Pwned 5+ Subscription)

- **GET/POST /stealer-logs-email** - Find stealer logs by email
- **GET/POST /stealer-logs-website** - Find stealer logs by website domain
- **GET/POST /stealer-logs-domain** - Find stealer logs by email domain

## Project Structure

```
demo/
├── app.rb                 # Main Sinatra application
├── config.yml.example     # Configuration template
├── config.yml             # Your API key (gitignored)
├── Gemfile                # Ruby dependencies
├── README.md              # This file
├── .gitignore             # Ignore config files
├── views/                 # ERB templates
│   ├── layout.erb         # Main layout
│   ├── index.erb          # Home page
│   ├── breached_account.erb
│   ├── breaches.erb
│   ├── breach.erb
│   ├── latest_breach.erb
│   ├── data_classes.erb
│   ├── pastes.erb
│   ├── pwned_passwords.erb
│   ├── breached_domain.erb
│   ├── subscribed_domains.erb
│   ├── subscription_status.erb
│   ├── stealer_logs_email.erb
│   ├── stealer_logs_website.erb
│   └── stealer_logs_domain.erb
└── public/                # Static assets (if needed)
```

## Development

### Adding New Features

1. Add a route in `app.rb`
2. Create a corresponding view in `views/`
3. Add navigation link in `views/layout.erb` if needed

### Error Handling

The app handles all HIBP API errors:
- `NotFoundError` - Account/breach not found
- `UnauthorizedError` - Invalid API key
- `ForbiddenError` - Missing user agent
- `RateLimitError` - Rate limit exceeded
- `BadRequestError` - Invalid request
- `ServiceUnavailableError` - API temporarily down

## API Rate Limits

Rate limits vary by subscription tier:

- **Pwned 1**: 10 requests/minute
- **Pwned 2**: 10 requests/minute
- **Pwned 3**: 100 requests/minute
- **Pwned 5+**: 100+ requests/minute

The app displays errors when rate limits are exceeded.

## Troubleshooting

### Port Already in Use

If port 4567 is in use, specify a different port:

```bash
ruby app.rb -p 3000
```

### "config.yml not found" Error

Make sure you've copied `config.yml.example` to `config.yml`:

```bash
cp config.yml.example config.yml
```

### API Errors

- **401 Unauthorized**: Check your API key in `config.yml`
- **403 Forbidden**: Ensure `user_agent` is set in `config.yml`
- **404 Not Found**: The email/breach doesn't exist in HIBP
- **429 Too Many Requests**: You've exceeded your rate limit

## Security Notes

- Never commit `config.yml` with real API keys
- The `.gitignore` file prevents accidental commits
- API keys are loaded at startup only
- Pwned Passwords uses k-anonymity to protect checked passwords

## Learn More

- [sorbet-hibp Gem Documentation](../README.md)
- [Have I Been Pwned API Docs](https://haveibeenpwned.com/API/v3)
- [Get an API Key](https://haveibeenpwned.com/API/Key)
- [Sinatra Documentation](http://sinatrarb.com/)

## License

This demo application is part of the sorbet-hibp gem and is available under the same [MIT License](../LICENSE).
