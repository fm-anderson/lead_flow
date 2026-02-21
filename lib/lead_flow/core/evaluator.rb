require "json"
require "open3"
require "shellwords"

module LeadFlow
  module Core
    class Evaluator
      def initialize(provider: :gemini_cli)
        @provider = provider
      end

      def confirm_intent?(lead, business_context:, business_solutions:)
        prompt = <<~PROMPT
          You are a Sales Discovery Assistant. I want you to find leads for MY business.

          MY BUSINESS CONTEXT:
          #{business_context}

          THE PROBLEMS I SOLVE:
          #{business_solutions}

          POST TO ANALYZE:
          TITLE: #{lead.title}
          CONTENT: #{lead.content}

          CLASSIFICATION CRITERIA:
          - YES: The author is facing a SPECIFIC, PERSONAL problem or need that MY business solves. They are ASKING for a solution, tool, or direct advice for their current situation.
          - NO: The author is just sharing general news, giving advice to others, posting a tutorial, or is a service provider marketing themselves.

          TASK: Based on MY business context, is this a high-intent lead that I can help with?
          FORMAT:
          REASONING: [1 sentence explaining how it relates to my business]
          FINAL_ANSWER: [YES/NO]
        PROMPT

        confirmed, reasoning = call_ai(prompt)
        [confirmed, reasoning]
      end

      private

      def call_ai(prompt)
        case @provider.to_sym
        when :gemini_cli
          call_gemini_cli(prompt)
        else
          raise "Unsupported AI provider: #{@provider}"
        end
      end

      def call_gemini_cli(prompt)
        # Use the gemini CLI in headless mode with gemini-2.5-flash
        cmd = "gemini --model gemini-2.5-flash --prompt #{Shellwords.escape(prompt)} --output-format text"
        stdout, stderr, status = Open3.capture3(cmd)

        if status.success?
          parse_answer(stdout.to_s)
        else
          puts "Gemini CLI Error: #{stderr}"
          [false, "Error: #{stderr}"]
        end
      end

      def parse_answer(full_text)
        # Extract reasoning and final answer from the CLI output
        reasoning = full_text.match(/REASONING:\s*(.*)/)&.captures&.first
        answer = (full_text.match(/FINAL_ANSWER:\s*(YES|NO)/)&.captures&.first || full_text).upcase
        
        [answer.include?("YES"), reasoning]
      end
    end
  end
end
