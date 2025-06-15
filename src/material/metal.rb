module Material
  class Metal
    attr_reader :albedo

    def initialize(albedo)
      @albedo = albedo
    end

    def scatter(ray, hit_record)
      reflected = ray.direction.reflect(hit_record.normal)
      Ray.new(hit_record.point, reflected)
    end
  end
end
