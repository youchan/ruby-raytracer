require_relative 'vec3'

class Ray
  attr_reader :origin, :direction

  def initialize(origin, direction)
    @origin = origin
    @direction = direction
  end

  def at(t)
    origin + direction * t
  end
end
