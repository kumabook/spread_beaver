# frozen_string_literal: true

class Range
  def interval
    be = self.begin == Float::INFINITY ? Time.now : self.begin
    en = self.end   == Float::INFINITY ? Time.now : self.end
    en - be
  end

  def twice_past
    be = self.begin == Float::INFINITY ? Time.now : self.begin
    (be - interval)..self.end
  end

  def twice_future
    en = self.end   == Float::INFINITY ? Time.now : self.end
    self.begin..(en + interval)
  end

  def previous(duration)
    (self.begin - duration)..(self.end - duration)
  end
end
