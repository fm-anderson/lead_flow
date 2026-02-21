require "spec_helper"
require "lead_flow"
require "net/http"

RSpec.describe LeadFlow::Connectors::RedditJson do
  let(:subreddit) { "freelance" }
  let(:user_agent) { "LeadFlow/1.0 (by /u/testuser)" }
  let(:connector) { described_class.new(subreddit: subreddit, user_agent: user_agent) }

  describe "#fetch" do
    let(:mock_json) do
      {
        "data" => {
          "after" => "t3_abc123",
          "children" => [
            {
              "data" => {
                "name" => "t3_post123",
                "author" => "test_user",
                "title" => "Need help with billing",
                "selftext" => "Does anyone know a good invoicing tool?",
                "permalink" => "/r/freelance/post123",
                "ups" => 10,
                "num_comments" => 5,
                "created_utc" => 1708455600,
                "subreddit" => "freelance"
              }
            }
          ]
        }
      }.to_json
    end

    let(:mock_response) do
      instance_double(Net::HTTPSuccess, 
        body: mock_json, 
        code: "200", 
        message: "OK",
        is_a?: true
      )
    end

    before do
      # Ensure Net::HTTPSuccess === mock_response returns true
      allow(Net::HTTPSuccess).to receive(:===).with(mock_response).and_return(true)
      allow(Net::HTTP).to receive(:start).and_return(mock_response)
    end

    it "fetches and normalizes Reddit posts into Lead objects" do
      leads = connector.fetch
      expect(leads.size).to eq(1)
      
      lead = leads.first
      expect(lead).to be_a(LeadFlow::Lead)
      expect(lead.source).to eq("reddit")
      expect(lead.external_id).to eq("t3_post123")
      expect(lead.author).to eq("test_user")
      expect(lead.title).to eq("Need help with billing")
      expect(lead.content).to eq("Does anyone know a good invoicing tool?")
      expect(lead.url).to eq("https://reddit.com/r/freelance/post123")
      expect(lead.metadata[:ups]).to eq(10)
    end

    it "sends the correct User-Agent header" do
      # Create a real request object to track its state
      request_spy = nil
      allow(Net::HTTP::Get).to receive(:new).and_wrap_original do |m, *args|
        request_spy = m.call(*args)
      end

      connector.fetch
      expect(request_spy["User-Agent"]).to eq(user_agent)
    end
  end
end
