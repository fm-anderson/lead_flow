require "spec_helper"
require "lead_flow"
require "tempfile"

RSpec.describe LeadFlow::Core::Deduplicator do
  let(:temp_file) { Tempfile.new("dedup_db") }
  let(:deduplicator) { described_class.new(storage_path: temp_file.path) }

  after do
    temp_file.close
    temp_file.unlink
  end

  describe "#duplicate?" do
    it "returns false for a new external_id" do
      expect(deduplicator.duplicate?("123")).to be false
    end

    it "returns true if the external_id was already added" do
      deduplicator.add("123")
      expect(deduplicator.duplicate?("123")).to be true
    end

    it "is persistent across instances and handles statuses" do
      deduplicator.add("abc", status: "FILTERED")
      deduplicator.add("def", status: "CONFIRMED")
      
      new_instance = described_class.new(storage_path: temp_file.path)
      expect(new_instance.duplicate?("abc")).to be true
      expect(new_instance.duplicate?("def")).to be true
      
      # Verify the file content format
      lines = File.readlines(temp_file.path, chomp: true)
      expect(lines).to include("abc FILTERED")
      expect(lines).to include("def CONFIRMED")
    end
  end

  describe "#add" do
    it "marks an ID as seen with a default status" do
      deduplicator.add("xyz")
      expect(deduplicator.duplicate?("xyz")).to be true
      expect(File.read(temp_file.path)).to include("xyz PROCESSED")
    end

    it "stores custom statuses" do
      deduplicator.add("custom123", status: "REJECTED")
      expect(File.read(temp_file.path)).to include("custom123 REJECTED")
    end
  end
end
