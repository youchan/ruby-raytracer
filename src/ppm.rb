require_relative 'camera'
require_relative 'sphere'
require_relative 'hittable_list'
require_relative 'material'

world = HittableList.new

material_ground = Material::Lambertian.new(Vec3.new(0.8, 0.8, 0.0))
material_center = Material::Lambertian.new(Vec3.new(0.1, 0.2, 0.5))
material_left   = Material::Metal.new(Vec3.new(0.8, 0.8, 0.8))
material_right  = Material::Metal.new(Vec3.new(0.8, 0.6, 0.2))

world << Sphere.new(Vec3.new( 0.0, -100.5, -1.0), 100.0, material_ground)
world << Sphere.new(Vec3.new( 0.0,    0.0, -1.2),   0.5, material_center)
world << Sphere.new(Vec3.new(-1.3,    0.0, -1.0),   0.5, material_left)
world << Sphere.new(Vec3.new( 1.3,    0.0, -1.0),   0.5, material_right)

camera = Camera.new(world)

puts 'P3'
puts "#{camera.image_width} #{camera.image_height}"
puts '256'

pixel_data = camera.render

pixel_data.each_with_index do |pixel, i|
  puts "#{pixel & 0xff} #{(pixel >> 8) & 0xff} #{(pixel >> 16) & 0xff}"
end

