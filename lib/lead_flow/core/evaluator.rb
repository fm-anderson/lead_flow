require "faraday"
require "json"

module LeadFlow
  module Core
    class Evaluator
      def initialize(api_key:, provider: :gemini)
        @api_key = api_key
        @provider = provider
      end

      # The "AI Brain" confirms if the user is actually looking for a service.
      def confirm_intent?(lead)
        prompt = <<~PROMPT
          You are a Lead Generation Assistant. Analyze this social media post:

          TITLE: #{lead.title}
          CONTENT: #{lead.content}

          CLASSIFICATION CRITERIA:
          - YES: The author is explicitly looking to BUY, HIRE, or FIND a professional tool/service (e.g., "Recommend a billing software", "I need an accountant", "What's the best tool for...").
          - NO: The author is just asking for advice, complaining, sharing news, or is a service provider themselves (e.g., "How do I do X?", "I hate this software", "Here is my blog post").

          TASK: Based on the criteria, is this a high-intent lead? 
          ANSWER: Respond with ONLY "YES" or "NO".
        PROMPT

        call_ai(prompt)
      end

      private

      def call_ai(prompt)
        case @provider.to_sym
        when :gemini
          call_gemini(prompt)
        else
          raise "Unsupported AI provider: #{@provider}"
        end
      end

      def call_gemini(prompt)
        url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=#{@api_key}"
        
        response = Faraday.post(url) do |req|
          req.headers["Content-Type"] = "application/json"
          req.body = {
            contents: [{ parts: [{ text: prompt }] }]
          }.to_json
        end

        return false unless response.success?

        result = JSON.parse(response.body)
        answer = result.dig("candidates", 0, "content", "parts", 0, "text").to_s.strip.upcase
        answer == "YES"
      rescue StandardError => e
        puts "AI Evaluation Error: #{e.message}"
        false
      end
    end
  end
end
