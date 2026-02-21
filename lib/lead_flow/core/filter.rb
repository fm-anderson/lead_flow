module LeadFlow
  module Core
    class Filter
      def initialize(keywords: [])
        # Regex for efficient matching 
        @regex = Regexp.union(keywords.map { |k| Regexp.new(k, Regexp::IGNORECASE) })
      end

      def match?(lead)
        # Match against title OR content
        [@regex.match?(lead.title.to_s), @regex.match?(lead.content.to_s)].any?
      end
    end
  end
end
