require "spec_helper"
require "lead_flow/lead"
require "lead_flow/notifiers/base"
require "lead_flow/notifiers/discord"

RSpec.describe LeadFlow::Notifiers::Discord do
  let(:webhook_url) { "https://discord.com/api/webhooks/test" }
  let(:notifier) { described_class.new(webhook_url: webhook_url) }
  let(:lead) do
    LeadFlow::Lead.new(
      source: "reddit",
      external_id: "123",
      author: "test_user",
      title: "Need help with invoicing",
      content: "I am looking for a simple billing tool for my freelance work.",
      url: "https://reddit.com/r/test",
      captured_at: Time.now
    )
  end

  describe "#notify" do
    it "sends a POST request to the webhook URL" do
      stub_request(:post, webhook_url).to_return(status: 204)

      result = notifier.notify(lead, reasoning: "They are looking for a simple tool.")
      expect(result).to be true
      expect(a_request(:post, webhook_url)).to have_been_made
    end

    it "returns false if no webhook URL is provided" do
      notifier_no_url = described_class.new(webhook_url: nil)
      expect(notifier_no_url.notify(lead)).to be false
    end
  end
end
