require "spec_helper"
require "lead_flow"

RSpec.describe LeadFlow::Core::Filter do
  let(:keywords) { ["invoice", "billing"] }
  let(:filter) { described_class.new(keywords: keywords) }

  describe "#match?" do
    it "returns true if a keyword is found in content" do
      lead = LeadFlow::Lead.new(content: "I need a better invoice tool!")
      expect(filter.match?(lead)).to be true
    end

    it "returns true if a keyword is found in title" do
      lead = LeadFlow::Lead.new(title: "New billing system help", content: "Looking for advice.")
      expect(filter.match?(lead)).to be true
    end

    it "is case insensitive" do
      lead = LeadFlow::Lead.new(content: "INVOICE software?")
      expect(filter.match?(lead)).to be true
    end

    it "returns false if no keywords match" do
      lead = LeadFlow::Lead.new(content: "How do I fix my car?")
      expect(filter.match?(lead)).to be false
    end
  end
end
