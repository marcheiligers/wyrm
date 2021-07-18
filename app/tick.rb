def tick(args)
  $snake ||= Snake.new
  $snake.tick(args)
end
