require "spec_helper"
require "lead_flow"

RSpec.describe LeadFlow::Connectors::Reddit do
  let(:client_id) { "fake_id" }
  let(:client_secret) { "fake_secret" }
  let(:subreddit) { "freelance" }
  let(:connector) do
    described_class.new(
      client_id: client_id,
      client_secret: client_secret,
      subreddit: subreddit,
      user_agent: "LeadFlow/1.0"
    )
  end

  describe "#fetch" do
    let(:mock_response) do
      {
        "data" => {
          "children" => [
            {
              "data" => {
                "id" => "post123",
                "author" => "test_user",
                "title" => "Need help with billing",
                "selftext" => "Does anyone know a good invoicing tool?",
                "url" => "https://reddit.com/r/freelance/post123",
                "created_utc" => 1708455600
              }
            }
          ]
        }
      }
    end

    it "fetches and normalizes Reddit posts into Leads" do
      # Mock the OAuth token and the posts fetch
      allow(connector).to receive(:get_token).and_return("token123")
      
      mock_faraday = instance_double(Faraday::Response, success?: true, body: mock_response.to_json)
      allow(Faraday).to receive(:get).and_return(mock_faraday)

      leads = connector.fetch
      expect(leads.first).to be_a(LeadFlow::Lead)
      expect(leads.first.source).to eq("reddit")
      expect(leads.first.external_id).to eq("post123")
      expect(leads.first.author).to eq("test_user")
      expect(leads.first.content).to eq("Does anyone know a good invoicing tool?")
    end
  end
end
