module Material
  class Lambertian
    attr_reader :albedo

    def initialize(albedo)
      @albedo = albedo
    end

    def scatter(ray, hit_record)
      scatter_direction = hit_record.normal + Vec3.random_unit_vector
      scatter_direction hit_record.normal if scatter_direction.near_zero
      Ray.new(hit_record.point, scatter_direction)
    end
  end
end
