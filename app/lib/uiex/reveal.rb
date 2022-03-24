class Reveal < Window
  include Easing

  # TODO: Events

  attr_reader :child

  def initialize(child, animation_length: 60)
    child.hide

    @child = child

    @animation = :none
    @visible = false
    @animation_length = animation_length
  end

  def id
    id ||= "reveal_target_#{@child.id}".to_sym
  end

  def animating?
    @animation != :none
  end

  def show
    @animation = :show
    @animation_ticks = 0
    @visible = false

    child.show
    create_render_target
  end

  def hide
    @animation = :hide
    @animation_ticks = 0
    @visible = false

    create_render_target
    child.hide
  end

  def handle_inputs
    @child.handle_inputs unless animating?
  end

  def to_primitives
    if animating?
      animated_to_primitives
    elsif visible?
      @child.to_primitives
    end
  end

  def animated_to_primitives
    @animation_ticks += 1

    if @animation_ticks == @animation_length
      notify_observers(Event.new(@animation == :show ? :shown : :hidden, self))
      @visible = true if @animation == :show
      @animation = :none
    end

    @render_sprite.sprite!(animated_hash)
  end

  def animated_hash
    {}
  end

private

  def create_render_target
    @render_target = $args.render_target(id)
    @render_target.primitives << @child.to_primitives
    @render_sprite = { x: @child.x, y: @child.y, w: @child.w, h: @child.h, source_x: @child.x, source_y: @child.y, source_w: @child.w, source_h: @child.h, path: id }
  end
end

class AppearReveal < Reveal
  def animated_hash
    if @animation == :show
      { a: @a = ease_in_quart(@animation_ticks, @animation_length) * 255 }
    elsif @animation == :hide
      { a: @a = (1 - ease_in_quart(@animation_ticks, @animation_length)) * 255 }
    end
  end
end

class WipeReveal < Reveal
  def animated_hash
    if @animation == :show
      {
        a: ease_in_quart(@animation_ticks, @animation_length) * 255,
        x: @child.x + (1 - ease_in_quart(@animation_ticks, @animation_length)) * @child.w
      }
    elsif @animation == :hide
      {
        a: (1 - ease_in_quart(@animation_ticks, @animation_length)) * 255,
        x: @child.x - ease_in_quart(@animation_ticks, @animation_length) * @child.w
      }
    end
  end
end

class DropReveal < Reveal
  def show
    super
    @animation_y = 720 + @child.h - @child.y
  end

  def hide
    super
    @animation_y = 720 + @child.h - @child.y
  end

  def animated_hash
    if @animation == :show
      { y: @y = (1 - ease_out_elastic(@animation_ticks, @animation_length)) * @animation_y + @child.y }
    elsif @animation == :hide
      { y: @y = ease_in_back(@animation_ticks, @animation_length) * @animation_y + @child.y }
    end
  end
end

class FuturisticTvReveal < Reveal
  def animated_hash
    state_length = @animation_length.idiv(2)

    if @animation == :show
      @animation_state ||= :horizontal
      case @animation_state
      when :horizontal
        aw = ease_in_quart(@animation_ticks, state_length) * @child.w
        ay = @child.y + @child.h / 2 - 3

        @animation_state = :vertical if @animation_ticks == state_length

        { x: @child.x + (@child.w - aw) / 2, y: ay, w: aw, h: 6 }
      when :vertical
        ah = ease_in_quart(@animation_ticks - state_length, state_length) * (@child.h - 6) + 6

        @animation_state = nil if @animation_ticks == @animation_length - 1

        { y: @child.y + (@child.h - ah) / 2, h: ah }
      end
    elsif @animation == :hide
      @animation_state ||= :vertical
      case @animation_state
      when :vertical
        ah = (1 - ease_in_quart(@animation_ticks, state_length)) * (@child.h - 6) + 6

        @animation_state = :horizontal if @animation_ticks == state_length

        { y: @child.y + (@child.h - ah) / 2, h: ah }
      when :horizontal
        aw = (1 - ease_in_quart(@animation_ticks - state_length, state_length)) * @child.w
        ay = @child.y + @child.h / 2 - 3

        @animation_state = nil if @animation_ticks == @animation_length - 1

        { x: @child.x + (@child.w - aw) / 2, y: ay, w: aw, h: 6 }
      end
    end
  end
end

class ZoomReveal < Reveal
  def animated_hash
    if @animation == :show
      p = ease_in_quart(@animation_ticks, @animation_length)
      aw = p * @child.w
      ah = p * @child.h
      { x: @child.x + (@child.w - aw) / 2, y: @child.y + (@child.h - ah) / 2, w: aw, h: ah }
    elsif @animation == :hide
      p = ease_in_quart(@animation_ticks, @animation_length)
      aw = p * @child.w * 2 + @child.w
      ah = p * @child.h * 2 + @child.h
      { x: @child.x + (@child.w - aw) / 2, y: @child.y + (@child.h - ah) / 2, w: aw, h: ah, a: (1 - p) * 255 }
    end
  end
end
