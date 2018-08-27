# frozen_string_literal: true

class Integer
  def to_time
    Time.zone.at(self / 1000)
  end
end
