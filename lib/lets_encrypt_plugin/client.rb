require "openssl"
require "acme-client"

module LetsEncryptPlugin
  class Client
    attr_reader :client
    attr_reader :contact

    def initialize
      key = OpenSSL::PKey::RSA.new(private_key)
      @client = Acme::Client.new(private_key: key, endpoint: endpoint)
    end

    def authorize(domain)
      client.authorize(domain: domain)
    rescue Acme::Client::Error::Unauthorized
      register
      retry
    end

    def create_challenge(authorization)
      authorization.http01
    end

    def validate(challenge)
      challenge.request_verification

      sleep(1)
      times = 0

      while times <= 15
        break unless challenge.verify_status == 'pending'
        times += 1
        sleep(1)
      end

      challenge
    end

    def request_certificate(key)
      csr = Acme::Client::CertificateRequest.new(
        common_name: LetsEncryptPlugin.configuration.domain,
        names:  LetsEncryptPlugin.configuration.domains,
        private_key: key
      )

      client.new_certificate(csr)
    end

    def register
      registration = client.register(contact: "mailto:#{email_contact}")
      registration.agree_terms
    end

    private

    def private_key
      LetsEncryptPlugin.configuration.private_key.tap do |key|
        if key.nil?
          raise <<-ERROR
private_key was not set. Please add the following to your LetsEncryptPlugin initializer:

  config.private_key = "YOUR KEY HERE"
ERROR
        end
      end
    end

    def email_contact
      LetsEncryptPlugin.configuration.email_contact.tap do |email|
        if email.nil?
          raise <<-ERROR
email_contact was not set. Please add the following to your LetsEncryptPlugin initializer:

  config.email_contact = "YOUR EMAIL"
ERROR
        end
      end
    end

    def endpoint
      LetsEncryptPlugin.configuration.endpoint
    end
  end
end
