require_relative 'vec3'
require_relative 'ray'
require_relative 'material'
require_relative 'utils'

class Camera
  attr_reader :image_width, :image_height
  attr_reader :u, :v, :w
  attr_reader :defocus_angle, :defocus_disk_u, :defocus_disk_v

  SAMPLES_PAR_PIXEL = 500
  PIXEL_SAMPLES_SCALE = 1.0 / SAMPLES_PAR_PIXEL
  MAX_DEPTH = 50
  ASPECT_RATIO = 16.0/9.0
  IMAGE_WIDTH = 1200

  def initialize(world,
    look_from: Vec3.new(0, 0, 0),
    look_at: Vec3.new(0, 0, -1),
    vup: Vec3.new(0, 1, 0),
    vfov: 90,
    defocus_angle: 0.0,
    focus_dist: 10.0
  )
    @world = world
    @defocus_angle = defocus_angle

    @image_width = IMAGE_WIDTH
    @image_height = (image_width / ASPECT_RATIO).floor
    @image_height = 1 if @image_height < 1

    @center = look_from

    # Determin viewport dimensions
    # @focal_length = (look_from - look_at).length
    theta = Math.degrees_to_radians(vfov)
    h = Math.tan(theta / 2)
    @viewport_height = 2 * h * focus_dist
    @viewport_width = @viewport_height * image_width.to_f / @image_height

    # Calculate the u,v,w unit basis vectors for the camera cordinate frame.
    @w = (look_from - look_at).unit_vector
    @u = vup.cross(@w).unit_vector
    @v = @w.cross(@u)

    # Calculate the vectors across the horizontal and down the vertical viewport edges.
    viewport_u = @viewport_width * @u
    viewport_v = @viewport_height * -@v

    # Calculate the horizontal and vertical delta vectors to the next pixel.
    @pixel_delta_u = viewport_u / @image_width
    @pixel_delta_v = viewport_v / @image_height

    # Calculate the location of the upper left pixel.
    viewport_upper_left = @center - (focus_dist * @w) - viewport_u / 2 - viewport_v / 2
    @pixel100_loc = viewport_upper_left + 0.5 * (@pixel_delta_u + @pixel_delta_v)

    # Calculate the camera defocus disk basis vectors.
    defocus_radius = focus_dist * Math.tan(Math.degrees_to_radians(defocus_angle / 2))
    @defocus_disk_u = u * defocus_radius
    @defocus_disk_v = v * defocus_radius
  end

  def ray(x, y)
    offset_x = rand - 0.5
    offset_y = rand - 0.5
    pixel_sample = @pixel100_loc +
                   ((x.to_f + offset_x) * @pixel_delta_u) +
                   ((y.to_f + offset_y) * @pixel_delta_v)
    ray_origin = defocus_angle <= 0 ? @center : defocus_disk_sample
    ray_direction = pixel_sample - ray_origin
    Ray.new(ray_origin, ray_direction)
  end

  def ray_color(ray, depth)
    return Vec3.new(0, 0, 0) if depth <= 0

    hit = @world.hit(ray, 0.001..Float::INFINITY)
    if hit
      scattered = hit.material.scatter(ray, hit)
      if scattered
        return hit.material.attenuation * ray_color(scattered, depth - 1)
      else
        return Vec3.new(0, 0, 0)
      end
    end

    unit_direction = ray.direction.unit_vector
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

  def render(&callback)
    image_data = Array.new(image_height * image_width)
    image_height.times do |j|
      image_width.times do |i|
        pixel_color = Vec3.new(0, 0, 0)
        SAMPLES_PAR_PIXEL.times do |sample|
          ray = ray(i, j)
          pixel_color += ray_color(ray, MAX_DEPTH)
        end
        color_num = color_to_i(pixel_color * PIXEL_SAMPLES_SCALE)
        image_data[j * image_width + i] = color_num
        callback.call(color_num, i, j)
      end
    end
    image_data
  end

  def defocus_disk_sample
    p = Vec3.random_in_unit_disk
    @center + (p.x * defocus_disk_u) + (p.y * defocus_disk_v)
  end
end
