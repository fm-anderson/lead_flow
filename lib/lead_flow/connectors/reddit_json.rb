require "net/http"
require "json"
require "uri"

module LeadFlow
  module Connectors
    class RedditJson < Base
      BASE_URL = "https://www.reddit.com/r/%s/new.json?limit=%d"

      def initialize(subreddit:, user_agent:, limit: 25)
        @subreddit = subreddit
        @user_agent = user_agent
        @limit = limit
      end

      def fetch(after: nil, limit: nil)
        limit ||= @limit
        url = sprintf(BASE_URL, @subreddit, limit)
        url += "&after=#{after}" if after

        uri = URI(url)
        request = Net::HTTP::Get.new(uri)
        request["User-Agent"] = @user_agent

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        case response
        when Net::HTTPSuccess
          process_response(JSON.parse(response.body))
        else
          puts "Reddit API Error: #{response.code} #{response.message}"
          []
        end
      rescue StandardError => e
        puts "Reddit Connector Error: #{e.message}"
        []
      end

      protected

      def normalize(data)
        LeadFlow::Lead.new(
          source: "reddit",
          external_id: data["name"],
          author: data["author"],
          title: data["title"],
          content: data["selftext"],
          url: "https://reddit.com#{data["permalink"]}",
          metadata: {
            subreddit: data["subreddit"],
            ups: data["ups"],
            num_comments: data["num_comments"]
          },
          captured_at: Time.at(data["created_utc"].to_i)
        )
      end

      private

      def process_response(json)
        children = json.dig("data", "children") || []
        children.map { |child| normalize(child["data"]) }
      end
    end
  end
end
