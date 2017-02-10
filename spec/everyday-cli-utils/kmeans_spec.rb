require_relative '../../lib/everyday-cli-utils'
include EverydayCliUtils
import :kmeans

def gen_arr(options = {}, &block)
  min = options[:min] || 1
  max = options[:max] || 4
  base_mult = options[:base_mult] || 100
  min2 = options[:min2] || min
  max2 = options[:max2] || max
  (min..max).to_a.flat_map { |v| (min2..max2).to_a.flat_map { |v2| [base_mult*v + block.call(v, v2), 100*v - block.call(v, v2)]}}
end

def expect_arr(actual_to_expected = {})
  actual_to_expected.each { |a, e|
    a = a.sort
    e = e.sort
    expect(a.count).to eq e.count
    expect(a).to eq e
  }
end

def expect_arr_two_deep(actual_to_expected = {})
  actual_to_expected.each { |a, e|
    a = a.sort
    e = e.sort
    expect(a.count).to eq e.count
    (0...a.count).each { |i|
      ai = a[i].sort
      ei = e[i].sort
      expect(ai).to eq ei
    }
  }
end

def expect_arr_count(actual_to_expected_count = {})
  actual_to_expected_count.each { |a, ec|
    expect(a.count).to eq ec
  }
end

describe EverydayCliUtils::Kmeans do
  it 'finds the right clusters in simple data' do
    arr    = gen_arr { |v, v2| Math.sqrt(v2) }
    expect_arr arr.nmeans => [100, 200, 300, 400]
  end

  it 'limits number of clusters found' do
    arr    = (1..50).to_a.map { |v| (v * (101-v)) ** 2 }
    expect_arr_count arr.nmeans(5) => 5, arr.nmeans(3) => 3
  end

  it 'finds outliers in simple data' do
    arr      = gen_arr { |v, v2| (v2+v)/v2 }
    expect_arr arr.outliers => [197, 203, 296, 304, 395, 405]
  end

  it 'finds the correct means when k is specified' do
    arr      = gen_arr { |v, v2| (v2+v)/v2 }
    expect_arr arr.kmeans(2) => [150, 350]
  end

  it 'finds the correct means when k is specified' do
    arr      = gen_arr { |v, v2| (v2+v)/v2 }
    kmeans = arr.kmeans(2)
    expect_arr_two_deep arr.get_clusters(kmeans) => [gen_arr(min: 1, max: 2, min2: 1, max2: 4) { |v, v2| (v2+v)/v2 }, gen_arr(min: 3, max: 4, min2: 1, max2: 4) { |v, v2| (v2+v)/v2 }]
  end
end