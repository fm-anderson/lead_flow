require "faraday"
require "json"

module LeadFlow
  module Notifiers
    class Discord < Base
      def initialize(webhook_url: ENV["DISCORD_WEBHOOK_URL"])
        @webhook_url = webhook_url
      end

      def notify(lead, reasoning: nil)
        return false unless @webhook_url

        payload = {
          embeds: [{
            title: "New Lead Found: #{lead.source.capitalize}",
            url: lead.url,
            color: 5814783, # Blurple
            fields: [
              { name: "Author", value: lead.author || "Unknown", inline: true },
              { name: "Title", value: lead.title.to_s[0..250] || "No Title" },
              { name: "Content Snippet", value: lead.content.to_s[0..500] + "..." },
              { name: "AI Reasoning", value: reasoning || "N/A" }
            ],
            footer: { text: "Lead Flow • #{lead.captured_at || Time.now}" }
          }]
        }

        response = Faraday.post(@webhook_url) do |req|
          req.headers["Content-Type"] = "application/json"
          req.body = payload.to_json
        end

        response.success?
      end
    end
  end
end
