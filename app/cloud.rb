class Cloud
  CLOUDS = [
    { w: 64, h: 64, id: 9 },
    { w: 64, h: 64, id: 10 }
  ]
  def initialize(anywhere: true)
    @v = (rand(10) + 1) / 10

    i = rand(CLOUDS.size)
    c = CLOUDS[i]
    z = PIXEL_MUL
    x = anywhere ? (rand(1000) + 140) : -c[:w] * PIXEL_MUL
    y = rand(720) - 50
    a = rand(100) + 150
    flip_horizontally = rand < 0.5
    flip_vertically = rand < 0.5

    @primitive = {
      x: x,
      y: y,
      w: c[:w] * PIXEL_MUL,
      h: c[:h] * PIXEL_MUL,
      a: a,
      path: "sprites/cloud#{c[:id]}.png",
      flip_horizontally: flip_horizontally,
      flip_vertically: flip_vertically,
      blendmode_enum: 1
    }.sprite!
  end

  def finished?
    @primitive[:x] + @primitive[:w] < 0 || @primitive[:x] > 1280
  end

  def to_p
    @primitive[:x] += @v
    @primitive
  end
end
