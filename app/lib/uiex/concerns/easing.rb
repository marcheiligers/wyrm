# https://easings.net

module Easing
  N1 = 7.5625
  D1 = 2.75
  def ease_out_bounce(pos, dur)
    x = pos / dur.to_f
    if x < 1 / D1
      return N1 * x * x;
    elsif x < 2 / D1
      return N1 * (x -= 1.5 / D1) * x + 0.75;
    elsif x < 2.5 / D1
      return N1 * (x -= 2.25 / D1) * x + 0.9375;
    else
      return N1 * (x -= 2.625 / D1) * x + 0.984375;
    end
  end

  C4 = (2 * Math::PI) / 3
  def ease_out_elastic(pos, dur)
    x = pos / dur.to_f
    return 0 if x <= 0
    return 1 if x >= 1

    2 ** (-10 * x) * Math.sin((x * 10 - 0.75) * C4) + 1;
  end

  C1 = 1.70158;
  C3 = C1 + 1;
  def ease_in_back(pos, dur)
    x = pos / dur.to_f
    return 0 if x <= 0
    return 1 if x >= 1

    C3 * x * x * x - C1 * x * x
  end

  def ease_in_quart(pos, dur)
    x = pos / dur.to_f
    return 0 if x <= 0
    return 1 if x >= 1

    x * x * x * x
  end
end