class Body
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
    body_sprite = if @length > @body.length
                    BodySprite.new(@wyrm.head, @wyrm.direction)
                  else
                    @body.shift.update(@wyrm.head, @wyrm.direction, false)
                  end

    @body << body_sprite
    @body.first.tail = true
  end

  def grow
    @length += 1
  end

  def exit_portal!
    @body = []
  end

  def include?(pos)
    @body.any? { |body| body.logical_position == pos }
  end

  def to_p(portal_length = 0)
    @body.first(@length - portal_length).map(&:to_p)
  end

  def to_s
    @body.map(&:to_s)
  end
end
