module LetsEncryptPlugin
  class Configuration
    attr_accessor :private_key, :endpoint, :email_contact, :domains

    def initialize
      @endpoint = endpoint_based_on_env
    end

    def domain
      domains.first
    end

    def alt_domains
      domains[1..-1]
    end

    def endpoint_based_on_env
      if Rails.env.production?
        "https://acme-v01.api.letsencrypt.org"
      else
        "https://acme-staging.api.letsencrypt.org"
      end
    end
  end
end
