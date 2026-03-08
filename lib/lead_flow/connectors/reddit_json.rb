require "net/http"
require "json"
require "uri"

module LeadFlow
  module Connectors
    class RedditJson < Base
      BASE_URL = "https://www.reddit.com/r/%s/new.json?limit=%d"

      # Internal error for handling retries
      class RateLimitError < StandardError; end

      def initialize(subreddit:, user_agent:, limit: 25)
        @subreddit = subreddit
        @user_agent = user_agent
        @limit = limit
      end

      def fetch(after: nil, limit: nil)
        retries = 0
        current_limit = limit || @limit
        url = sprintf(BASE_URL, @subreddit, current_limit)
        url += "&after=#{after}" if after
        uri = URI(url)

        begin
          response = make_request(uri)

          if response.code == "429"
            raise RateLimitError, response["retry-after"]
          end

          case response
          when Net::HTTPSuccess
            process_response(JSON.parse(response.body))
          else
            warn "\n[!] Reddit API Error: #{response.code} #{response.message} (r/#{@subreddit})"
            []
          end
        rescue RateLimitError => e
          if (retries += 1) < 3
            wait_time = e.message&.to_i || (2**retries * 30)
            warn "\n[!] Rate limited on r/#{@subreddit}. Sleeping for #{wait_time}s..."
            sleep(wait_time)
            retry
          else
            warn "[!] Max retries reached for r/#{@subreddit}"
            []
          end
        rescue SocketError => e
          if (retries += 1) < 3
            warn "\n[!] DNS/Network Error: #{e.message}. Retrying in 5s..."
            sleep(5)
            retry
          else
            warn "\n[!] Reddit Connector Error: #{e.message}"
            []
          end
        rescue StandardError => e
          warn "\n[!] Reddit Connector Error: #{e.message}"
          []
        end
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

      def make_request(uri)
        request = Net::HTTP::Get.new(uri)
        request["User-Agent"] = @user_agent

        Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end
      end

      def process_response(json)
        children = json.dig("data", "children") || []
        # Filter out stickied/pinned posts as they are usually old/rules
        children.reject! { |child| child.dig("data", "stickied") == true }
        children.map { |child| normalize(child["data"]) }
      end
    end
  end
end
