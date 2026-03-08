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
          You are a Lead Qualifier. Your job is to protect my time by only approving high-intent leads who are actively LOOKING for a solution to buy or use.

          MY BUSINESS CONTEXT:
          #{business_context}

          THE PROBLEMS I SOLVE:
          #{business_solutions}

          POST TO ANALYZE:
          TITLE: #{lead.title}
          CONTENT: #{lead.content}

          CLASSIFICATION CRITERIA:
          - YES: The author is a SEEKER facing a SPECIFIC, PERSONAL problem or need that MY business solves. They are expressing personal frustration, asking for tool recommendations, or asking "How do I solve [Problem]?" for their own business or current situation.
          - NO: The author is a SHARER or BUILDER. They are showing off a project, asking for feedback/critics, sharing a "Show HN" style post, or marketing their own service/app.
          
          STRICT EXCLUSIONS (Always NO):
          1. "Check out my app" or "I built this" posts.
          2. "Looking for feedback" or "critiques appreciated" posts.
          3. Tutorials, "How I built X" stories, or "I'm launching X" announcements.

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
        # Use the gemini CLI in headless mode with gemini-3-flash
        cmd = "gemini --model gemini-3-flash --prompt #{Shellwords.escape(prompt)} --output-format text"
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
