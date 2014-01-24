require_relative 'safe/kmeans'

module Enumerable
  def outliers(sensitivity = 0.5, k = nil)
    EverydayCliUtils::Kmeans.outliers(self, sensitivity, k)
  end

  def nmeans(max_k = 10, threshold = 0.05)
    EverydayCliUtils::Kmeans.nmeans(self, max_k, threshold)
  end

  def kmeans(k)
    EverydayCliUtils::Kmeans.kmeans(self, k)
  end

  def get_clusters(means)
    EverydayCliUtils::Kmeans.get_clusters(self, means)
  end
end