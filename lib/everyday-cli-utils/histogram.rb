require_relative 'maputil'

module Enumerable
  def histogram(ks = nil, width = 100, height = 50)
    mi     = min
    ma     = max
    diff   = ma - mi
    step   = diff.to_f / (width.to_f - 1)
    counts = Array.new(width, 0)
    each { |v|
      i         = ((v - mi).to_f / step.to_f).floor
      counts[i] += 1
    }
    max_y = counts.max
    lines = Array.new(height) { ' ' * width }
    (0...width).each { |i|
      h = ((counts[i].to_f / max_y.to_f) * height.to_f).round
      ((height - h)...height).each { |j|
        lines[j][i] = '#'
      }
      if h == 0 && counts[i] > 0
        lines[height - 1][i] = '_'
      end
    }
    unless ks.nil?
      lines[height] = ' ' * width
      ks.each { |v|
        i                = ((v - mi) / step).to_i
        lines[height][i] = '|'
      }
    end
    lines
  end
end