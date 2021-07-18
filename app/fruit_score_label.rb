class FruitScoreLabel
  FONT = 'fonts/MayflowerAntique.ttf'
  WHITE_FADE_DURATION = 25
  RED_FADE_DURATION = 5
  TOTAL_FADE_DURATION = WHITE_FADE_DURATION + RED_FADE_DURATION

  def initialize(x, y, text, size, outline = 1, move = 30)
    @x = x
    @y = y
    @text = text
    @size = size
    @outline = outline
    @move = move
    reset
  end

  def finished?
    @animating == true && @animation_start + TOTAL_FADE_DURATION < $gtk.args.state.tick_count
  end

  def white_fade_finished?
    @animating == true && @animation_start + WHITE_FADE_DURATION < $gtk.args.state.tick_count
  end

  def reset
    @animating = false
    @animation_start = 0
  end

  def animate
    return if @animating

    @animating = true
    @animation_start = $gtk.args.state.tick_count
  end

  def to_p
    if @animating
      if finished?
        white_animation_progress = 1
        red_animation_progress = 1
      elsif white_fade_finished?
        white_animation_progress = 1
        red_animation_progress = $gtk.args.easing.ease @animation_start + WHITE_FADE_DURATION, $gtk.args.state.tick_count, RED_FADE_DURATION, :quad
      else
        white_animation_progress = $gtk.args.easing.ease @animation_start, $gtk.args.state.tick_count, WHITE_FADE_DURATION, :quad
        red_animation_progress = 0
      end

      if finished?
        move_animation_progress = 1
      else
        move_animation_progress = $gtk.args.easing.ease @animation_start, $gtk.args.state.tick_count, TOTAL_FADE_DURATION, :quad
      end
    else
      white_animation_progress = 0
      red_animation_progress = 0
      move_animation_progress = 0
    end

    white_alpha = 255 * (1 - white_animation_progress)
    red_alpha = 255 * (1 - red_animation_progress)
    dy = @move * move_animation_progress

    [
      {
        x:                       @x - @outline,
        y:                       @y - @outline + dy,
        text:                    @text,
        size_enum:               @size,
        r:                       255,
        g:                       255,
        b:                       255,
        a:                       white_alpha,
        font:                    FONT,
        alignment_enum:          1,
        vertical_alignment_enum: 1, # 0 is bottom, 1 is middle, 2 is top
      }.label,
      {
        x:                       @x - @outline,
        y:                       @y + @outline + dy,
        text:                    @text,
        size_enum:               @size,
        r:                       255,
        g:                       255,
        b:                       255,
        a:                       white_alpha,
        font:                    FONT,
        alignment_enum:          1,
        vertical_alignment_enum: 1, # 0 is bottom, 1 is middle, 2 is top
      }.label,
      {
        x:                       @x + @outline,
        y:                       @y - @outline + dy,
        text:                    @text,
        size_enum:               @size,
        r:                       255,
        g:                       255,
        b:                       255,
        a:                       white_alpha,
        font:                    FONT,
        alignment_enum:          1,
        vertical_alignment_enum: 1, # 0 is bottom, 1 is middle, 2 is top
      }.label,
      {
        x:                       @x + @outline,
        y:                       @y + @outline + dy,
        text:                    @text,
        size_enum:               @size,
        r:                       255,
        g:                       255,
        b:                       255,
        a:                       white_alpha,
        font:                    FONT,
        alignment_enum:          1,
        vertical_alignment_enum: 1, # 0 is bottom, 1 is middle, 2 is top
      }.label,
      {
        x:                       @x,
        y:                       @y + dy,
        text:                    @text,
        size_enum:               @size,
        r:                       155,
        g:                       50,
        b:                       50,
        a:                       red_alpha,
        font:                    FONT,
        alignment_enum:          1,
        vertical_alignment_enum: 1, # 0 is bottom, 1 is middle, 2 is top
      }.label
    ]
  end
end
