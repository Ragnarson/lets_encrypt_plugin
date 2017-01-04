require "rails_helper"

describe LetsEncryptPlugin::Client do
  subject { described_class.new }
  let(:acme_client) { double(Acme::Client) }

  before do
    default_configuration
    allow_any_instance_of(LetsEncryptPlugin::Client).to receive(:client).and_return(acme_client)
  end

  describe "initializes" do
    let(:registration) { double }
    let(:key) { double }

    it "registers and accepts terms" do
      expect(OpenSSL::PKey::RSA).to receive(:new).
        with(LetsEncryptPlugin.configuration.private_key).
        and_return(key)

      expect(Acme::Client).to receive(:new).
        with(private_key: key,
             endpoint: LetsEncryptPlugin.configuration.endpoint).
        and_return(acme_client)

      subject
    end
  end

  describe "#authorize" do
    it "creates an authorization with domain" do
      expect(acme_client).to receive(:authorize).with(domain: "example.com")
      subject.authorize("example.com")
    end

    context "if unauthorized" do
      it "registers and retries authorization" do
        expect(acme_client).to receive(:authorize).with(domain: "example.com").
          once.
          and_raise(Acme::Client::Error::Unauthorized.new("No registration exists matching provided key"))

        expect(acme_client).to receive(:authorize).with(domain: "example.com").
          once.and_return(true)

        expect(subject).to receive(:register)
        expect(subject.authorize("example.com")).to eq(true)
      end
    end
  end

  describe "#create_challenge" do
    let(:authorization) { double }

    it "creates a http challenge" do
      expect(authorization).to receive(:http01)
      subject.create_challenge(authorization)
    end
  end

  describe "#validate" do
    let(:authorization) { double }
    let(:challenge) { double }

    before { allow(subject).to receive(:sleep) }

    it "http challenge" do
      expect(challenge).to receive(:request_verification)

      expect(challenge).to receive(:verify_status).once.and_return("pending")
      expect(challenge).to receive(:verify_status).once.and_return("valid")
      subject.validate(challenge)
    end
  end

  describe "#request_certificate" do
    let(:csr) { double }
    let(:key) { double }

    it "creates new certificated based on CSR" do
      expect(Acme::Client::CertificateRequest).to receive(:new).
        with({common_name: "example.com",
              names: ["example.com", "www.example.com"],
              private_key: key}).and_return(csr)

      expect(acme_client).to receive(:new_certificate).with(csr)

      subject.request_certificate(key)
    end
  end
end
