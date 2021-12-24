module Numbers
  def draw_number(x, y, num)
    num.to_s.chars.map_with_index do |ch, i|
      {
        x: x + i * 32,
        y: y,
        w: 32,
        h: 32,
        path: 'sprites/numbers.png',
        source_x: (ch.ord - 48) * 16,
        source_y: 0,
        source_w: 16,
        source_h: 16
      }
    end
  end
end