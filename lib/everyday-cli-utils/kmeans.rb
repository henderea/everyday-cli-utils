require_relative 'maputil'

def normal(x, avg, std)
  exp = -(((x - avg) / std) ** 2) / 2
  ((Math.exp(exp) / (std * Math.sqrt(2 * Math::PI))))
end

def f_test(clusters, means, cnt, avg)
  ev   = 0
  cnt2 = clusters.count { |i| !i.empty? }
  (0...means.count).each { |i|
    unless clusters[i].empty?
      ni = clusters[i].count
      ev += ni * ((means[i] - avg) ** 2)
    end
  }
  ev /= cnt2 - 1
  uv = 0
  (0...means.count).each { |i|
    unless clusters[i].empty?
      (0...clusters[i].count).each { |j|
        uv += (clusters[i][j] - means[i]) * (clusters[i][j] - means[i])
      }
    end
  }
  uv /= (cnt - cnt2)
  (ev / uv)
end

def f_test2(clusters, means, cnt)
  uv   = 0
  cnt2 = clusters.count { |i| !i.empty? }
  (0...means.count).each { |i|
    unless clusters[i].empty?
      tmp = 0
      (0...clusters[i].count).each { |j|
        tmp += (clusters[i][j] - means[i]) ** 2
      }
      tmp /= clusters[i].count
      uv  += Math.sqrt(tmp)
    end
  }
  (uv / (cnt - cnt2))
end

module Enumerable
  def outliers(sensitivity = 0.5, k = nil)
    if k.nil?
      ks = nmeans
    else
      ks = kmeans(k)
    end
    cs = get_clusters(ks)

    def normal(x, avg, std)
      exp = -(((x - avg) / std) ** 2) / 2
      ((Math.exp(exp) / (std * Math.sqrt(2 * Math::PI))))
    end

    outliers = []

    ks.each_with_index { |avg, i|
      csi      = cs[i]
      std      = csi.std_dev
      cnt      = csi.count
      outliers += csi.select { |c|
        (normal(c, avg, std) * cnt) < sensitivity
      }
    }
    outliers
  end

  def nmeans(max_k = 10, threshold = 0.05)
    su  = sum
    cnt = count
    avg = su / cnt
    ks1 = kmeans(1)
    if cnt == 1
      return ks1
    end
    cso = get_clusters(ks1)
    ft1 = f_test2(cso, ks1, cnt)
    ks  = kmeans(2)
    cs  = get_clusters(ks)
    ft  = f_test(cs, ks, cnt, avg)
    ft2 = f_test2(cs, ks, cnt)
    (3..[max_k, cnt].min).each { |k|
      kso  = ks
      fto  = ft
      fto2 = ft2
      ks   = kmeans(k)
      cs   = get_clusters(ks)
      ft   = f_test(cs, ks, cnt, avg)
      ft2  = f_test2(cs, ks, cnt)
      if ((ft - fto) / fto) < threshold && fto2 < ft1
        return kso
      end
    }
    ft2 >= ft1 ? ks1 : ks
  end

  def kmeans(k)
    mi   = min
    ma   = max
    diff = ma - mi
    ks   = []
    (1..k).each { |i|
      ks[i - 1] = mi + (i * (diff / (k + 1)))
    }
    kso = false
    while ks != kso
      kso      = ks
      clusters = get_clusters(kso)
      ks       = []
      clusters.each_with_index { |val, key|
        cnt = val.count
        if cnt <= 0
          ks[key] = kso[key]
        else
          sum     = val.sum
          ks[key] = (sum / cnt)
        end
      }
      ks.sort
    end
    ks
  end

  def get_clusters(means)
    clusters = Array.new(means.count) { Array.new }
    each { |item|
      cluster  = false
      distance = false
      (0...means.count).each { |i|
        diff = (means[i] - item).abs
        if distance == false || diff < distance
          cluster  = i
          distance = diff
        end
      }
      clusters[cluster][clusters[cluster].count] = item
    }
    clusters
  end
end