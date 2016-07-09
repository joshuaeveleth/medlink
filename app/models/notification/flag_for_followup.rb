module Notification
  class FlagForFollowup < Notification::Base
    def initialize response:, count:
      @response, @count = response, count
    end

    def text
      "Flagged response #{@response.id} for manual follow-up after #@count reminders"
    end
  end
end
