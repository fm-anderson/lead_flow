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
        when :gemini, :gemini_cli
          call_gemini_cli(prompt)
        else
          raise "Unsupported AI provider: #{@provider}"
        end
      end

      def call_gemini_cli(prompt)
        model = ENV.fetch("GEMINI_MODEL", "gemini-3-flash-preview")
        cmd = "gemini --model #{model} --non-interactive -"
        
        stdout_str = ""
        stderr_str = ""

        Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
          stdin.puts(prompt)
          stdin.close
          
          stdout_str = stdout.read
          stderr_str = stderr.read
          status = wait_thr.value
          
          if status.success?
            return parse_answer(stdout_str)
          else
            return [false, "Error: #{stderr_str}"]
          end
        end
      rescue StandardError => e
        [false, "Runtime Error: #{e.message}"]
      end

      def parse_answer(full_text)
        # 1. Clean up the text: Remove Markdown bolding and extra whitespace
        clean_text = full_text.gsub(/\*\*|__/, "").strip

        # 2. Extract Reasoning: Look for the line starting with REASONING
        reasoning_match = clean_text.match(/REASONING:\s*(.*?)(?=FINAL_ANSWER:|\z)/im)
        reasoning = reasoning_match ? reasoning_match[1].strip : "No reasoning provided."

        # 3. Extract Final Answer: Look for YES or NO
        answer_match = clean_text.match(/FINAL_ANSWER:\s*(YES|NO)/i)
        
        if answer_match
          confirmed = answer_match[1].upcase == "YES"
        else
          confirmed = clean_text.upcase.include?("YES")
        end

        [confirmed, reasoning]
      end
    end
  end
end
