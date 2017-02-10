require_relative 'maputil'

module EverydayCliUtils
  module KmeansUtil
    def self.normal(x, avg, std)
      exp = -(((x - avg) / std) ** 2.0) / 2.0
      ((Math.exp(exp) / (std * Math.sqrt(2.0 * Math::PI))))
    end

    def self.f_test(clusters, means, cnt, avg)
      cnt2 = clusters.count { |i| !i.empty? }
      ev   = f_test_ev(avg, clusters, cnt2, means)
      uv   = f_test_uv(clusters, cnt, cnt2, means)
      (ev / uv)
    end

    def self.f_test_ev(avg, clusters, cnt2, means)
      ev = 0.0
      (0...means.count).each { |i| ev += clusters[i].empty? ? 0.0 : clusters[i].count * ((means[i] - avg) ** 2.0) }
      ev / (cnt2 - 1.0)
    end

    def self.f_test_uv(clusters, cnt, cnt2, means)
      uv = 0.0
      (0...means.count).each { |i| uv = f_test_uvi(clusters, i, means, uv) }
      uv / (cnt - cnt2)
    end

    def self.f_test_uvi(clusters, i, means, uv)
      (0...clusters[i].count).each { |j| uv += (clusters[i][j] - means[i]) * (clusters[i][j] - means[i]) } unless clusters[i].empty?
      uv
    end

    def self.f_test2(clusters, means, cnt)
      uv   = 0.0
      cnt2 = clusters.count { |i| !i.empty? }
      (0...means.count).each { |i| uv += f_test2_calc(clusters, i, means, uv) unless clusters[i].empty? }
      (uv / (cnt - cnt2))
    end

    def self.f_test2_calc(clusters, i, means, uv)
      tmp = 0.0
      (0...clusters[i].count).each { |j| tmp += (clusters[i][j] - means[i]) ** 2.0 }
      tmp /= clusters[i].count
      Math.sqrt(tmp)
    end

    def self.get_clusters(collection, means)
      clusters = Array.new(means.count) { Array.new }
      collection.each { |item|
        cluster  = false
        distance = false
        (0...means.count).each { |i|
          diff = (means[i] - item) ** 2
          if distance == false || diff <= distance
            cluster  = i
            distance = diff
          end
        }
        clusters[cluster] << item
      }
      clusters
    end

    def self.find_outliers(avg, cs, i, sensitivity)
      csi = cs[i]
      std = EverydayCliUtils::MapUtil.std_dev(csi)
      cnt = csi.count
      csi.select { |c| (normal(c, avg, std) * cnt) < sensitivity }
    end
  end
  module Kmeans
    def self.nmeans_setup_1(collection)
      su  = EverydayCliUtils::MapUtil.sum(collection)
      cnt = collection.count
      avg = su / cnt
      ks1 = kmeans(collection, 1)
      return avg, cnt, ks1
    end

    def self.nmeans_setup_2(collection, avg, cnt, ks1)
      cso = EverydayCliUtils::KmeansUtil.get_clusters(collection, ks1)
      ft1 = EverydayCliUtils::KmeansUtil.f_test2(cso, ks1, cnt)
      ks  = kmeans(collection, 2)
      cs  = EverydayCliUtils::KmeansUtil.get_clusters(collection, ks)
      ft  = EverydayCliUtils::KmeansUtil.f_test(cs, ks, cnt, avg)
      ft2 = EverydayCliUtils::KmeansUtil.f_test2(cs, ks, cnt)
      return ft, ft1, ft2, ks
    end

    def self.run_nmean(collection, avg, cnt, ft, ft2, k, ks)
      kso  = ks
      fto  = ft
      fto2 = ft2
      ks   = kmeans(collection, k)
      cs   = EverydayCliUtils::KmeansUtil.get_clusters(collection, ks)
      ft   = EverydayCliUtils::KmeansUtil.f_test(cs, ks, cnt, avg)
      ft2  = EverydayCliUtils::KmeansUtil.f_test2(cs, ks, cnt)
      return ft, ft2, fto, fto2, ks, kso
    end

    def self.run_nmeans(avg, cnt, collection, ft, ft1, ft2, ks, ks1, max_k, threshold)
      (3..[max_k, cnt].min).each { |k|
        ft, ft2, fto, fto2, ks, kso = run_nmean(collection, avg, cnt, ft, ft2, k, ks)
        return kso if ((ft - fto) / fto) < threshold && fto2 < ft1
      }
      ft2 >= ft1 ? ks1 : ks
    end

    def self.run_kmean(collection, ks)
      kso      = ks
      clusters = EverydayCliUtils::KmeansUtil.get_clusters(collection, kso)
      ks       = []
      clusters.each_with_index { |val, key| ks[key] = (val.count <= 0) ? false : (val.sum / val.count) }
      min = collection.min
      max = collection.max
      ks = ks.map { |k| k || ((Random.rand * (max-min)) + min) }
      ks = ks.sort
      return kso, ks
    end

    def self.kmeans(collection, k)
      mi   = collection.min
      ma   = collection.max
      diff = ma - mi
      ks   = []
      (1..k).each { |i| ks[i - 1] = mi + (i * (diff / (k + 1.0))) }
      kso = false
      while ks != kso
        kso, ks = run_kmean(collection, ks)
      end
      ks
    end

    def self.nmeans(collection, max_k = 10, threshold = 0.05)
      collection    = EverydayCliUtils::MapUtil.floats(collection)
      avg, cnt, ks1 = nmeans_setup_1(collection)
      return ks1 if cnt == 1
      ft, ft1, ft2, ks = nmeans_setup_2(collection, avg, cnt, ks1)
      run_nmeans(avg, cnt, collection, ft, ft1, ft2, ks, ks1, max_k, threshold)
    end

    def self.outliers(collection, sensitivity = 0.5, k = nil)
      ks = k.nil? ? nmeans(collection) : kmeans(collection, k)
      cs = EverydayCliUtils::KmeansUtil.get_clusters(collection, ks)

      outliers = []

      ks.each_with_index { |avg, i| outliers += EverydayCliUtils::KmeansUtil.find_outliers(avg, cs, i, sensitivity) }
      outliers
    end

    def self.get_clusters(collection, means)
      EverydayCliUtils::KmeansUtil.get_clusters(collection, means)
    end
  end
end