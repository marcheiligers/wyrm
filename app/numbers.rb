module Numbers
  def draw_number(x, y, num, a = 255)
    num.to_s.chars.map_with_index do |ch, i|
      {
        x: x + i * GRID_SIZE,
        y: y,
        w: GRID_SIZE,
        h: GRID_SIZE,
        path: 'sprites/numbers3.png',
        a: a,
        source_x: (ch.ord - 48) * 10,
        source_y: 0,
        source_w: 10,
        source_h: 10
      }
    end
  end
end
