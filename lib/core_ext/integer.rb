class Integer
  def to_time
    Time.at(self / 1000)
  end
end
