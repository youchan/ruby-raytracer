require_relative 'utils'

class HittableList
  def initialize
    @hittables = []
  end

  def <<(hittable)
    @hittables << hittable
  end

  def hit(ray, ray_t = 0..Float::INFINITY)
    rec = nil
    closest_so_far = ray_t.max

    @hittables.each do |hittable|
      temp_rec = hittable.hit(ray, ray_t.min..closest_so_far)
      if temp_rec
        closest_so_far = temp_rec.t
        rec = temp_rec
      end
    end

    rec
  end
end
