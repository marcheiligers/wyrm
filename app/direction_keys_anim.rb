class DirectionKeysAnim
  FRAME_LENGTHS = [104, 208, 312].freeze
  TOTAL_TICKS = FRAME_LENGTHS.last

  def initialize
    @ticks = 0
    @frame = 0

    @sprite = {
      x: 240,
      y: 240,
      w: 30 * PIXEL_MUL,
      h: 20 * PIXEL_MUL,
      path: 'sprites/direction_keys.png',
      source_y: 0,
      source_w: 30,
      source_h: 20
    }
  end

  def to_p
    @ticks += 1
    @frame += 1 if @ticks > FRAME_LENGTHS[@frame]
    if @frame >= FRAME_LENGTHS.length
      @ticks = 0
      @frame = 0
    end

    @sprite.sprite!(y: 240, source_x: @frame * 30)
  end
end
