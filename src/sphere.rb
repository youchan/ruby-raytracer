require_relative 'hit_record'
require_relative 'surrounds'

class Sphere
  attr_reader :center, :radius, :material

  def initialize(center, radius, material)
    @center = center
    @radius = radius
    @material = material
  end

  def hit(ray, ray_t = 0..Float::INFINITY)
    oc = center - ray.origin
    a = ray.direction.dot(ray.direction)
    h = ray.direction.dot(oc)
    c = oc.dot(oc) - radius ** 2

    discriminant = h ** 2 - a * c

    return nil if discriminant < 0

    sqrtd = Math.sqrt(discriminant)
    root = (h - sqrtd) / a
    unless ray_t.surrounds?(root)
      root = (h + sqrtd) / a
      unless ray_t.surrounds?(root)
        return nil
      end
    end

    point = ray.at(root)
    HitRecord.new(
      ray: ray,
      point: point,
      outward_normal: (point - center) / radius,
      t: root,
      material: material
    )
  end
end
