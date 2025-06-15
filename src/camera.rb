require_relative 'vec3'
require_relative 'ray'
require_relative 'material'

class Camera
  attr_reader :image_width, :image_height

  SAMPLES_PAR_PIXEL = 100
  PIXEL_SAMPLES_SCALE = 1.0 / SAMPLES_PAR_PIXEL
  MAX_DEPTH = 50

  def initialize(world, aspect_ratio: 16.0/9.0, image_width: 400, focal_length: 1.0, viewport_height: 2.0)
    @world = world
    @image_width = image_width
    @image_height = (image_width / aspect_ratio).floor
    @image_height = 1 if @image_height < 1
    @focal_length = focal_length
    @viewport_height = viewport_height
    @viewport_width = viewport_height * image_width.to_f / @image_height
    @camera_center = Vec3.new(0, 0, 0)

    viewport_u = Vec3.new(@viewport_width, 0, 0)
    viewport_v = Vec3.new(0, -@viewport_height, 0)

    @pixel_delta_u = viewport_u / @image_width
    @pixel_delta_v = viewport_v / @image_height

    viewport_upper_left = @camera_center - Vec3.new(0, 0, @focal_length) - viewport_u / 2 - viewport_v / 2
    @pixel100_loc = viewport_upper_left + 0.5 * (@pixel_delta_u + @pixel_delta_v)
  end

  def ray(x, y)
    offset_x = rand - 0.5
    offset_y = rand - 0.5
    pixel_sample = @pixel100_loc + ((x.to_f + offset_x) * @pixel_delta_u) + ((y.to_f + offset_y) * @pixel_delta_v)
    ray_direction = pixel_sample - @camera_center
    Ray.new(@camera_center, ray_direction)
  end

  def ray_color(ray, depth)
    return Vec3.new(0, 0, 0) if depth <= 0

    hit = @world.hit(ray, 0.001..Float::INFINITY)
    if hit
      scattered = hit.material.scatter(ray, hit)
      if scattered
        return hit.material.albedo * ray_color(scattered, depth - 1)
      else
        return Vec3.new(0, 0, 0)
      end
    end

    unit_direction = Vec3.unit_vector(ray.direction)
    a = 0.5 * (unit_direction.y + 1.0)
    (1.0 - a) * Vec3.new(1.0, 1.0, 1.0) + a * Vec3.new(0.5, 0.7, 1.0)
  end

  def linear_to_gamma(linear_component)
    linear_component > 0 ? Math.sqrt(linear_component) : 0.0
  end

  def color_to_i(pixcel_color)
    r = linear_to_gamma(pixcel_color.x)
    g = linear_to_gamma(pixcel_color.y)
    b = linear_to_gamma(pixcel_color.z)

    # Translate the (0..1) component values to the byte range (0..255).
    intensity = 0.000..0.999
    rbyte = (256 * intensity.clamp(r)).floor
    gbyte = (256 * intensity.clamp(g)).floor
    bbyte = (256 * intensity.clamp(b)).floor

    rbyte | gbyte << 8 | bbyte << 16
  end

  def render(&block)
    image_data = Array.new(image_height * image_width)
    image_height.times do |j|
      block.call(j + 1) if block
      image_width.times do |i|
        pixel_color = Vec3.new(0, 0, 0)
        SAMPLES_PAR_PIXEL.times do |sample|
          ray = ray(i, j)
          pixel_color += ray_color(ray, MAX_DEPTH)
        end
        image_data[j * image_width + i] = color_to_i(pixel_color * PIXEL_SAMPLES_SCALE)
      end
    end
    image_data
  end
end
