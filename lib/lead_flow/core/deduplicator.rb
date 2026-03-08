require "set"
require "fileutils"

module LeadFlow
  module Core
    class Deduplicator
      def initialize(storage_path: "db/seen_ids.txt")
        @storage_path = storage_path
        ensure_storage_exists
        @seen_ids = load_ids
      end

      def duplicate?(external_id)
        @seen_ids.include?(external_id.to_s)
      end

      def add(external_id, status: "PROCESSED")
        id = external_id.to_s
        return if @seen_ids.include?(id)

        @seen_ids.add(id)
        persist_id(id, status)
      end

      private

      def ensure_storage_exists
        dir = File.dirname(@storage_path)
        Dir.mkdir(dir) unless Dir.exist?(dir)
        FileUtils.touch(@storage_path) unless File.exist?(@storage_path)
      end

      def load_ids
        # Load only the ID (lines also contain status)
        File.readlines(@storage_path, chomp: true).map { |line| line.split(/\s+/).first }.to_set
      end

      def persist_id(id, status)
        File.open(@storage_path, "a") { |f| f.puts("#{id} #{status}") }
      end
    end
  end
end
