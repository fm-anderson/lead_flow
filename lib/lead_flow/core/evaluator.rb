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
        # Prepare the prompt for the AI
        prompt = <<~PROMPT
          Analyze the following text from a social platform:
          
          TITLE: #{lead.title}
          CONTENT: #{lead.content}
          
          TASK: Is the author clearly looking for a professional service or tool (e.g., invoicing software, billing tool, etc.)?
          Answer ONLY "YES" or "NO".
        PROMPT

        # Call the appropriate AI provider
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
