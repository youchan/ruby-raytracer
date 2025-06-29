require_relative 'camera'
require_relative 'sphere'
require_relative 'hittable_list'
require_relative 'material'

world = HittableList.new

ground_material = Material::Lambertian.new(Vec3.new(0.5, 0.5, 0.5))
world << Sphere.new(Vec3.new( 0.0, -1000.0, -1.0), 1000.0, ground_material)

(-11..11).each do |a|
  (-11..11).each do |b|
    choose_mat = rand
    center = Vec3.new(a + 0.9 * rand, 0.2, b + 0.9 * rand)
    if (center - Vec3.new(4, 0.2, 0)).length > 0.9
      case
      when choose_mat < 0.8
        albedo = Vec3.random * Vec3.random
        sphere_material = Material::Lambertian.new(albedo)
        world << Sphere.new(center, 0.2, sphere_material)
      when choose_mat < 0.95
        albedo = Vec3.random(0.5..1.0)
        fuzz = rand(0.0..0.5)
        sphere_material = Material::Metal.new(albedo, fuzz)
        world << Sphere.new(center, 0.2, sphere_material)
      else
        sphere_material = Material::Dielectric.new(1.5)
        world << Sphere.new(center, 0.2, sphere_material)
      end
    end
  end
end

material1 = Material::Dielectric.new(1.5)
world << Sphere.new(Vec3.new(0, 1, 0), 1.0, material1)

material2 = Material::Lambertian.new(Vec3.new(0.4, 0.2, 0.1))
world << Sphere.new(Vec3.new(-4, 1, 0), 1.0, material2)

material3 = Material::Metal.new(Vec3.new(0.7, 0.6, 0.5), 0.0)
world << Sphere.new(Vec3.new(4, 1, 0), 1.0, material3)

camera = Camera.new(
  world,
  look_from: Vec3.new(13, 2, 3),
  look_at: Vec3.new(0, 0, 0),
  vup: Vec3.new(0, 1, 0),
  vfov: 20,
  defocus_angle: 0.6,
  focus_dist: 10.0
)

File.open('test.ppm', 'wb') do |file|
  file.puts 'P3'
  file.puts "#{camera.image_width} #{camera.image_height}"
  file.puts '256'

  pixel_data = camera.render do |pixel, i, j|
    puts "Line = #{j}/#{camera.image_height}" if i == 0
    file.puts "#{pixel & 0xff} #{(pixel >> 8) & 0xff} #{(pixel >> 16) & 0xff}"
  end
end
