class HorizontalRule < Window
  def initialize(**args)
    args[:h] ||= 2
    args[:color] ||= Color::DARK_GREY
    args[:focussable] ||= false

    super(args)
  end
end
