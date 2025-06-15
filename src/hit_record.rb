class HitRecord
  attr_reader :point, :normal, :t, :front_face, :material

  def initialize(ray:, point:, outward_normal:, t:, material:)
    @front_face = ray.direction.dot(outward_normal) < 0
    @normal = front_face ? outward_normal : -outward_normal
    @point = point
    @t = t
    @material = material
  end
end
