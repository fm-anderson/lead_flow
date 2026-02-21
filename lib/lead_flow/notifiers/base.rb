module LeadFlow
  module Notifiers
    class Base
      def notify(lead, reasoning: nil)
        raise NotImplementedError, "#{self.class} must implement #notify"
      end
    end
  end
end
