class Cloud
  CLOUDS = [
    { w: 640, h: 427 },
    { w: 128, h: 64 },
    { w: 64, h: 32 },
    { w: 64, h: 32 },
    { w: 64, h: 32 }
  ]
  def initialize(anywhere: true)
    @v = (rand(10) + 1) / 10

    i = rand(3) + 2
    c = CLOUDS[i]
    z = 8
    x = anywhere ? (rand(1000) + 140) : -c[:w] * z
    y = rand(720) - 50
    a = rand(100) + 25
    r = 0

    @primitive = { x: x, y: y, w: c[:w] * z, h: c[:h] * z, a: a, path: "sprites/cloud#{i}.png", angle: r }.sprite!
  end

  def finished?
    @primitive[:x] + @primitive[:w] < 0 || @primitive[:x] > 1280
  end

  def to_p
    @primitive[:x] += @v
    @primitive
  end
end
