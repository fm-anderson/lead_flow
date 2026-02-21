module LeadFlow
  module Connectors
    class Base
      def fetch
        raise NotImplementedError, "#{self.class} must implement #fetch"
      end

      protected

      def normalize(raw_data)
        raise NotImplementedError, "#{self.class} must implement #normalize"
      end
    end
  end
end
