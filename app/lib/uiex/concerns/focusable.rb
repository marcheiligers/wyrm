module Focusable
  attr_accessor :focussable

  def initialize(**args)
    super(args)

    @focussed = args.fetch(:focussed, false)
    @focussable = args.fetch(:focussable, true) # TODO: should this be the default?
  end

  def focussed?
    @focussed
  end

  def focussable?
    @focussable
  end

  def focus
    return if @focussed || !@focussable

    @focussed = true
    notify_observers(Event.new(:focussed, self))
    self
  end

  def blur
    return unless @focussed

    @focussed = false
    notify_observers(Event.new(:blurred, self))
    self
  end

  def blur_children(except = nil)
    @children.each { |child| child.blur unless child == except }
  end

  def focussed_child_index
    @children.index(&:focussed?)
  end
end
