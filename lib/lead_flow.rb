require "zeitwerk"
require "dotenv/load"

loader = Zeitwerk::Loader.for_gem
loader.setup

module LeadFlow
  class Error < StandardError; end
  # Root namespace for the Lead Flow engine
end
