require_relative 'maputil'

module EverydayCliUtils
  class Histogram
    def self.setup(collection, height, width)
      mi     = collection.min
      ma     = collection.max
      diff   = ma - mi
      step   = diff.to_f / (width.to_f - 1)
      counts = Array.new(width, 0)
      collection.each { |v| counts[((v - mi).to_f / step.to_f).floor] += 1 }
      max_y = counts.max
      lines = Array.new(height) { ' ' * width }
      return counts, lines, max_y, mi, step
    end

    def self.add_graph(counts, height, lines, max_y, width)
      (0...width).each { |i|
        h = ((counts[i].to_f / max_y.to_f) * height.to_f).round
        ((height - h)...height).each { |j|
          lines[j][i] = '#'
        }
        if h == 0 && counts[i] > 0
          lines[height - 1][i] = '_'
        end
      }
    end

    def self.add_averages(height, ks, lines, mi, step, width)
      lines[height] = ' ' * width
      ks.each { |v| lines[height][((v - mi) / step).to_i] = '|' }
    end
  end
end

module Enumerable
  def histogram(ks = nil, width = 100, height = 50)
    counts, lines, max_y, mi, step = EverydayCliUtils::Histogram.setup(self, height, width)
    EverydayCliUtils::Histogram.add_graph(counts, height, lines, max_y, width)
    EverydayCliUtils::Histogram.add_averages(height, ks, lines, mi, step, width) unless ks.nil?
    lines
  end
end