class HoldAnim
	FRAME_LENGTHS = [8, 16, 80]
	TOTAL_TICKS = FRAME_LENGTHS.last

  BASE_SPRITE = {
    x: 260,
    y: 200,
    w: 20 * PIXEL_MUL,
    h: 10 * PIXEL_MUL,
    path: 'sprites/hold-anim.png',
    source_y: 0,
    source_w: 20,
    source_h: 10
  }

  def initialize
  	@ticks = 0
  	@frame = 0
  end

  def to_p
    @ticks = @ticks + 1
    @frame += 1 if @ticks > FRAME_LENGTHS[@frame]
    if @frame >= FRAME_LENGTHS.length
    	@ticks = 0
    	@frame = 0
    end

    BASE_SPRITE.sprite!(source_x: @frame * 20)
  end
end
