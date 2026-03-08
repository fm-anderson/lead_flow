require "spec_helper"
require "lead_flow"

RSpec.describe LeadFlow::Core::Evaluator do
  let(:evaluator) { described_class.new(provider: :gemini_cli) }

  describe "#confirm_intent?" do
    let(:lead) { LeadFlow::Lead.new(content: "I'm looking for an invoicing tool for my small business.") }
    let(:context) { "I sell invoicing software." }
    let(:solutions) { "Billing automation." }

    it "returns true if the AI confirms intent" do
      allow(evaluator).to receive(:call_ai).and_return([true, "Matches context."])
      expect(evaluator.confirm_intent?(lead, business_context: context, business_solutions: solutions).first).to be true
    end

    it "returns false if the AI does not confirm intent" do
      allow(evaluator).to receive(:call_ai).and_return([false, "Irrelevant."])
      expect(evaluator.confirm_intent?(lead, business_context: context, business_solutions: solutions).first).to be false
    end
  end
end
