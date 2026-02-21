require "spec_helper"
require "lead_flow"

RSpec.describe LeadFlow::Core::Evaluator do
  let(:api_key) { "fake_key" }
  let(:evaluator) { described_class.new(api_key: api_key, provider: :gemini) }

  describe "#confirm_intent?" do
    let(:lead) { LeadFlow::Lead.new(content: "I'm looking for an invoicing tool for my small business.") }

    it "returns true if the AI confirms intent" do
      allow(evaluator).to receive(:call_ai).and_return(true)
      expect(evaluator.confirm_intent?(lead)).to be true
    end

    it "returns false if the AI does not confirm intent" do
      allow(evaluator).to receive(:call_ai).and_return(false)
      expect(evaluator.confirm_intent?(lead)).to be false
    end
  end
end
