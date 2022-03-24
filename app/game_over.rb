# class GameOver < MenuBase
#   def initialize
#     super('game_over')
#     add_static({ x: 360, y: 320, w: 560, h: 80, path: 'sprites/game-over.png' }.sprite!)
#     add_static(press_space)
#   end

#   def press_space
#     {
#       x: GRID_CENTER - (180.idiv(2) * PIXEL_MUL),
#       y: GRID_MIDDLE + (20.idiv(2) * PIXEL_MUL) - GRID_SIZE * 4,
#       w: 180 * PIXEL_MUL,
#       h: 20 * PIXEL_MUL,
#       path: 'sprites/press-space.png'
#     }.sprite!
#   end
# end