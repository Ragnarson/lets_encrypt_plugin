require "rails_helper"

describe LetsEncryptPlugin::Configuration do
  before do
    LetsEncryptPlugin.configure do |config|
      config.domains = %w(example.com www.example.com)
    end
  end

  describe "#domain" do
    it "returns first domain from domains" do
      expect(LetsEncryptPlugin.configuration.domain).to eq("example.com")
    end
  end

  describe "#alt_domains" do
    it "returns array of domains except first one" do
      expect(LetsEncryptPlugin.configuration.alt_domains).to eq(%w(www.example.com))
    end
  end
end
