require "rails_helper"

describe LetsEncryptPlugin::Certificate, model: true do
  subject { described_class.new }
  let(:client) { double(LetsEncryptPlugin::Client) }

  before do
    default_configuration
    allow(subject).to receive(:client).and_return(client)
  end

  describe "#generate" do
    let(:rsa_key) { double(to_pem: "key") }
    let(:new_cert) { double(to_pem: "cert", chain_to_pem: "chain") }
    let(:logger) { double }

    before do
      allow( OpenSSL::PKey::RSA).to receive(:new).
        and_return(rsa_key)
      allow(subject).to receive(:logger).and_return(logger)
    end

    it "requests a certificate and outputs to log" do
      expect(subject).to receive(:create_and_validate_challenges).
        and_return([double(status: "valid")])
      expect(client).to receive(:request_certificate).
        with(rsa_key).and_return(new_cert)

      expect(logger).to receive(:info).with("cert")
      expect(logger).to receive(:info).with("chain")
      expect(logger).to receive(:info).with("key")

      subject.generate
    end
  end

  describe "#create_and_validate_challenges" do
    let(:authorization) { double }

    before do
      LetsEncryptPlugin.configure { |c| c.domains = %w(example.com) }

      allow(client).to receive(:authorize).with("example.com").
        and_return(authorization)
    end

    context "valid authorization" do
      let(:authorization) { double(status: "valid") }

      it "returns valid challenge" do
        expect(client).to receive(:create_challenge).with(authorization).
          and_return(true)
        expect(subject.create_and_validate_challenges).to eq([true])
      end
    end

    context "pending authorization" do
      let(:authorization) { double(status: "pending") }
      let(:acme_challenge) { double(file_content: "abc", token: "123") }

      it "creates challenge, saves it and validates" do
        expect(client).to receive(:create_challenge).with(authorization).
          and_return(acme_challenge)
        expect(client).to receive(:validate).with(acme_challenge).
          and_return(true)
        expect(LetsEncryptPlugin::Challenge).to receive(:create!).
          with(content: "abc", token: "123")

        expect(subject.create_and_validate_challenges).to eq([true])
      end
    end
  end
end
