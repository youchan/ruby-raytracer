module Material
  class Dielectric
    attr_reader :refraction_index

    def initialize(refraction_index)
      @refraction_index = refraction_index
    end

    def scatter(ray, hit_record)
      ri = hit_record.front_face ? 1.0 / refraction_index : refraction_index
      unit_direction = ray.direction.unit_vector
      cos_theta = [-unit_direction.dot(hit_record.normal), 1.0].min
      sin_theta = Math.sqrt(1.0 - cos_theta ** 2)

      cannot_refrect = ri * sin_theta > 1.0

      if cannot_refrect || reflectance(cos_theta, ri) > rand
        direction = unit_direction.reflect(hit_record.normal)
      else
        direction = unit_direction.refract(hit_record.normal, ri)
      end
      Ray.new(hit_record.point, direction)
    end

    def attenuation
      Vec3.new(1.0, 1.0, 1.0)
    end

    def reflectance(cosin, refraction_index)
      r0 = ((1 - refraction_index) / (1 + refraction_index)) ** 2
      r0 + (1 - r0) * (1 - cosin) ** 5
    end
  end
end
