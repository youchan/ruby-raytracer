class Range
  def surrounds?(x)
    self.begin < x && x < self.end
  end

  def clamp(x)
    return self.begin if x < self.begin
    return self.end if x > self.end
    x
  end
end
