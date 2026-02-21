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
        id = external_id.to_s
        return true if @seen_ids.include?(id)

        @seen_ids.add(id)
        persist_id(id)
        false
      end

      private

      def ensure_storage_exists
        dir = File.dirname(@storage_path)
        Dir.mkdir(dir) unless Dir.exist?(dir)
        FileUtils.touch(@storage_path) unless File.exist?(@storage_path)
      end

      def load_ids
        File.readlines(@storage_path, chomp: true).to_set
      end

      def persist_id(id)
        File.open(@storage_path, "a") { |f| f.puts(id) }
      end
    end
  end
end
