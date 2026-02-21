require "spec_helper"
require "lead_flow"
require "tempfile"

RSpec.describe LeadFlow::Core::Deduplicator do
  let(:temp_file) { Tempfile.new("dedup_db") }
  let(:deduplicator) { described_class.new(storage_path: temp_file.path) }

  after do
    temp_file.unlink
  end

  describe "#duplicate?" do
    it "returns false for a new external_id" do
      expect(deduplicator.duplicate?("123")).to be false
    end

    it "returns true if the external_id was already seen" do
      deduplicator.duplicate?("123")
      expect(deduplicator.duplicate?("123")).to be true
    end

    it "is persistent across instances" do
      deduplicator.duplicate?("abc")
      
      new_instance = described_class.new(storage_path: temp_file.path)
      expect(new_instance.duplicate?("abc")).to be true
    end
  end
end
