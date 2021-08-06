class Body
  BODY_DEFAULTS = { w: GRID_SIZE, h: GRID_SIZE, path: 'sprites/body3.png' }

  def initialize(wyrm)
    @wyrm = wyrm
    reset
  end

  def reset
    @length = 2
    @body = []
  end

  def move
    @body << [*@wyrm.head, @wyrm.direction] if @length > 0
    @body.shift unless @length >= @body.length
  end

  def grow
    @length += 1
  end

  def include?(pos)
    @body.any? { |part| part[0] == pos[0] && part[1] == pos[1] }
  end

  def to_p
    @body.map { |part| body_sprite(part) }
  end

  def body_sprite(part)
    angle = case part[2]
            when :right then 0
            when :up then 90
            when :left then 180
            when :down then 270
            end

    { x: part.x * GRID_SIZE, y: part.y * GRID_SIZE, angle: angle }.sprite!(BODY_DEFAULTS)
  end
end
