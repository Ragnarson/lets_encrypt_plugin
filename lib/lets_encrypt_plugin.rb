require "lets_encrypt_plugin/engine"
require "lets_encrypt_plugin/configuration"
require "lets_encrypt_plugin/client"

module LetsEncryptPlugin
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end

  class Certificate
    def generate
      all_challenges = create_and_validate_challenges

      if all_challenges.all? { |challenge| challenge.status == "valid" }
        key = OpenSSL::PKey::RSA.new(4096)
        newcert = client.request_certificate(key)

        logger.info newcert.to_pem
        logger.info newcert.chain_to_pem
        logger.info key.to_pem
      else
        raise "Validation failed, unable to request certificate"
      end
    end

    def create_and_validate_challenges
      domains.map do |domain|
        authorization = client.authorize(domain)

        case authorization.status
        when "valid"
          client.create_challenge(authorization)
        when "pending"
          challenge = client.create_challenge(authorization)
          Challenge.create!(content: challenge.file_content, token: challenge.token)
          client.validate(challenge)
        end
      end
    end

    private

    def domains
      LetsEncryptPlugin.configuration.domains.tap do |domains|
        if domains.blank?
          raise <<-ERROR
domains was not set. Please add the following to your LetsEncryptPlugin initializer:

  config.domains = ["example.com", "www.example.com"]

Note the order is important, first domain is used as common name.
ERROR
        end
      end
    end

    def client
      @client ||= Client.new
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
