class Body
  BODY_DEFAULTS = { w: GRID_SIZE, h: GRID_SIZE, path: 'sprites/body3.png' }
  TAIL_DEFAULTS = { 
    w: GRID_SIZE, 
    h: GRID_SIZE, path: 'sprites/tail1.png',
    source_y: 0,
    source_w: 10,
    source_h: 10
  }
  TAIL_FRAMES = [0, 1, 2, 1, 3, 4]
  TICKS_PER_FRAME = 10

  attr_reader :length

  def initialize(wyrm)
    @wyrm = wyrm
    reset
    @tail_frame = 0
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
    @body.map_with_index { |part, index| index > 0 ? body_sprite(part) : tail_sprite(part) }
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

  def tail_sprite(part)
    angle = case part[2]
            when :right then 0
            when :up then 90
            when :left then 180
            when :down then 270
            end

    @tail_frame = (@tail_frame + 1) % TAIL_FRAMES.length if $args.tick_count % TICKS_PER_FRAME == 0

    { 
      x: part.x * GRID_SIZE, 
      y: part.y * GRID_SIZE,
      source_x: TAIL_FRAMES[@tail_frame] * 10,
      angle: angle 
    }.sprite!(TAIL_DEFAULTS)
  end
end
