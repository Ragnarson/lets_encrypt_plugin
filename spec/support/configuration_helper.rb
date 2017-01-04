module ConfigurationHelper
  def default_configuration
    LetsEncryptPlugin.configure do |config|
      config.email_contact = "john@example.com"
      config.domains       = %w(example.com www.example.com)
      config.private_key   = File.read(File.expand_path("../../fixtures/private_key.pem", __FILE__))
    end
  end
end
