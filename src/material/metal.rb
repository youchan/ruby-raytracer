module Material
  class Metal
    attr_reader :albedo, :fuzz

    def initialize(albedo, fuzz = 0.0)
      @albedo = albedo
      @fuzz = fuzz
    end

    def scatter(ray, hit_record)
      reflected = ray.direction.reflect(hit_record.normal)
      fuzzed = reflected.unit_vector + (fuzz * Vec3.random_unit_vector)
      scattered = Ray.new(hit_record.point, fuzzed)

      scattered.direction.dot(hit_record.normal) > 0 ? scattered : nil
    end

    def attenuation
      albedo
    end
  end
end
