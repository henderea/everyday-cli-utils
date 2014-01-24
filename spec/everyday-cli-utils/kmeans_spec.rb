require_relative '../../lib/everyday-cli-utils'
EverydayCliUtils.import :kmeans

describe EverydayCliUtils::Kmeans do
  it 'finds the right clusters in simple data' do
    arr    = [100, 200, 99, 400, 98, 201, 101, 405, 102]
    nmeans = arr.nmeans
    nmeans.count.should eq 3
    nmeans.should eq [100, 200.5, 402.5]
  end

  it 'limits number of clusters found' do
    arr    = (1..50).to_a.map { |v| (v * (101-v)) ** 2 }
    nmeans = arr.nmeans(5)
    nmeans.count.should eq 5
    nmeans = arr.nmeans(3)
    nmeans.count.should eq 3
  end

  it 'finds outliers in simple data' do
    arr      = [100, 200, 99, 400, 98, 201, 101, 405, 102]
    outliers = arr.outliers
    outliers.should eq [400.0, 405.0]
  end
end