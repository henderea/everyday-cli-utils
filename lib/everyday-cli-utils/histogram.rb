require_relative 'safe/histogram'

module Enumerable
  def histogram(ks = nil, width = 100, height = 50)
    EverydayCliUtils::Histogram.histogram(self, ks, width, height)
  end
end