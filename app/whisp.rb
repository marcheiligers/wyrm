class Whisp
  ANIM_FRAMES = 6
  TICKS_PER_FRAME = 6

#    STATE   SPRITE_FRAME    PASSAGE OF      HOW LONG   HOW MANY
#      |          |             TIME         TO SHOW    IMAGES
#      |          |              |           AN IMAGE   TO FLIP THROUGH
#      |          |              |               |      |
# state.sprite_frame =     state.tick_count.idiv(4).mod(6)
#                                            |       |
#                                            |       +- REMAINDER OF DIVIDE
#                                     DIVIDE EVENLY
#                                     (NO DECIMALS)


  def initialize(x, y)
    @x = x
    @y = y
    @frame = 0 
    @start_tick = $args.tick_count
    @alpha = rand(100) + 50
  end

  def to_p
    @frame += 1 if ($args.tick_count - @start_tick) % TICKS_PER_FRAME == 0

    {
      x: @x,
      y: @y,
      w: 128,
      h: 128,
      a: @alpha,
      path: 'sprites/whisp1.png',
      source_x: @frame * 64,
      source_y: 0,
      source_w: 64,
      source_h: 64
    }.sprite!
  end

  def finished?
    @frame >= ANIM_FRAMES
  end
end
