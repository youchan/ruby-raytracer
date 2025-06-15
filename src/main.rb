require 'js'
require_relative 'camera'
require_relative 'sphere'
require_relative 'hittable_list'
require_relative 'material'

title = JS.global[:document].getElementById('title')
title[:innerText] = 'Hello world'
progress = JS.global[:document].getElementById('progress')

canvas = JS.global[:document].getElementById('canvas')
ctx = canvas.getContext('2d')

JS.global.setTimeout(-> {
  world = HittableList.new

  material_ground = Material::Lambertian.new(Vec3.new(0.8, 0,8, 0.0))
  material_center = Material::Lambertian.new(Vec3.new(0.1, 0,2, 0.5))
  material_left = Material::Metal.new(Vec3.new(0.8, 0,8, 0.8))
  material_right = Material::Metal.new(Vec3.new(0.8, 0,6, 0.2))

  world << Sphere.new(Vec3.new(0.0, -100.5, -1.0), 100.0, material_ground)
  world << Sphere.new(Vec3.new(0.0, 0.0, -1.2), 0.5, material_center)
  world << Sphere.new(Vec3.new(-1.0, 0.0, -1.0), 0.5, material_left)
  world << Sphere.new(Vec3.new(1.0, 0.0, -1.0), 0.5, material_right)

  camera = Camera.new(world)

  canvas[:width] = camera.image_width
  canvas[:height] = camera.image_height

  pixel_data = camera.render do |line|
    Fiber.new do
      #progress[:innerText] = "Progress: #{line}/#{camera.image_height}"
      puts "Progress: #{line}/#{camera.image_height}"
    end.transfer
  end

  image_data = ctx.createImageData(camera.image_width, camera.image_height)

  pixel_data.each_with_index do |pixel, i|
    image_data[:data][i * 4 + 0] = pixel & 0xff
    image_data[:data][i * 4 + 1] = (pixel >> 8) & 0xff
    image_data[:data][i * 4 + 2] = (pixel >> 16) & 0xff
    image_data[:data][i * 4 + 3] = 255
  end

  ctx.putImageData(image_data, 0, 0)
}, 0)
