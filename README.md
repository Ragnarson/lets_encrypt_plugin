# LetsEncryptPlugin
Rails engine for generating Let's Encrypt certificates

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'lets_encrypt_plugin', git: "https://github.com/Ragnarson/lets_encrypt_plugin.git"
```

And then execute:
```bash
$ bundle
```

## Configuration

### Initializer
Create an initializer in `config/initializers` with

```ruby
LetsEncryptPlugin.configure do |config|
  config.domains = %w(example.com www.example.com)
  config.email_contact  = "whois@example.com"
  config.private_key = "KEY CONTENT" # File.read("server.key")

  # config.endpoint = "https://acme-v01.api.letsencrypt.org"
end
```

All domains have to point to your application otherwise validation will fail and
certificate won't be generated.

Email and private key are used for Let's Encrypt registration. To generate
private key you may use

```bash
openssl genrsa -out server.key 4096
```

Endpoint will be set based on `Rails.env` to either
`https://acme-v01.api.letsencrypt.org` for production or
`https://acme-staging.api.letsencrypt.org` for any other environment.

### Database migrations

Challenges will be stored in database for validation purposes.

Copy migrations to your application and run them:

```bash
rake lets_encrypt_plugin:install:migrations

rake db:migrate
```

### Mounting engine

Mount LetsEncryptPlugin at the top of `routes.rb`:

```ruby
  mount LetsEncryptPlugin::Engine, at: '/'
```

## Usage


## TODO

* Generator for initializer
* Different output
* Release on rubygems.org

## Contributing
Pull requests are welcome

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
