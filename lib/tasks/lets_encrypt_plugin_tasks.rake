desc "Generate SSL certificate using Let's Encrypt"
task lets_encrypt_plugin: :environment do
  LetsEncryptPlugin::Certificate.new.generate
end
