class Vec3
  attr_reader :x, :y, :z

  def initialize(*arr)
    @x = arr[0].to_f
    @y = arr[1].to_f
    @z = arr[2].to_f
  end

  def length_squared
    x ** 2 + y ** 2 + z ** 2
  end

  def length
    Math.sqrt(length_squared)
  end

  def add(vec)
   @x += vec.x
   @y += vec.y
   @z += vec.z
   self
  end

  def mul(t)
   @x *= t
   @y *= t
   @z *= t
   self
  end

  def div(t)
    mul(1/t)
  end

  def -@
    Vec3.new(-self.x, -self.y, -self.z)
  end

  def +(v)
    Vec3.new(self.x + v.x, self.y + v.y, self.z + v.z)
  end

  def -(v)
    Vec3.new(self.x - v.x, self.y - v.y, self.z - v.z)
  end

  def *(v)
    case v
    when Float
      Vec3.new(@x * v, @y * v, @z * v)
    when Vec3
      Vec3.new(@x * v.x, @y * v.y, @z * v.z)
    end
  end

  def /(v)
    Vec3.new(@x / v, @y / v, @z / v)
  end

  def near_zero
    s = 1e-8
    (x.abs < s) && (y.abs < s) && (z.abs < s)
  end

  def reflect(n)
    self - 2 * self.dot(n) * n
  end

  def refract(n, etai_over_etat)
    cos_theta = [-self.dot(n), 1.0].min
    r_out_prep = etai_over_etat * (self + cos_theta * n)
    r_out_parallel = -Math.sqrt((1.0 - r_out_prep.length_squared).abs) * n
    r_out_prep + r_out_parallel
  end

  def dot(v)
    self.x * v.x + self.y * v.y + self.z * v.z
  end

  def cross(v)
    Vec3.new(
      self.y * v.z - self.z * v.y,
      self.z * v.x - self.x * v.z,
      self.x * v.y - self.y * v.x
    )
  end

  def to_s
    "[#{x}, #{y}, #{z}]"
  end

  def unit_vector
    self / self.length
  end

  def self.random(range = 0.0...1.0)
    Vec3.new(rand(range), rand(range), rand(range))
  end

  def self.random_unit_vector
    loop do
      p = Vec3.random(-1.0..1.0)
      lensq = p.length_squared
      if 1e-160 < lensq && lensq <= 1
        return p / Math.sqrt(lensq)
      end
    end
  end

  def self.random_on_hemisphere(normal)
    on_unit_sphere = random_unit_vector
    if on_unit_sphere.dot(normal) > 0.0
      on_unit_sphere
    else
      -on_unit_sphere
    end
  end

  def self.random_in_unit_disk
    loop do
      p = Vec3.new(rand(-1.0..1.0), rand(-1.0..1.0), 0)
      return p if p.length_squared < 1
    end
  end
end

class Float
  alias_method :__mul__, :*

  def *(v)
    case v
    when Vec3
      Vec3.new(self.__mul__(v.x), self.__mul__(v.y), self.__mul__(v.z))
    else
      self.__mul__(v)
    end
  end

  private :__mul__
end
