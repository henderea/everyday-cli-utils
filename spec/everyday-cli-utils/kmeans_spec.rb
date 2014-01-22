require_relative '../../lib/everyday-cli-utils/kmeans'

describe EverydayCliUtils::Kmeans do
  it 'finds the right clusters in simple data' do
    arr    = [100, 200, 99, 400, 98, 201, 101, 405, 102]
    nmeans = arr.nmeans
    nmeans.count.should be 3
    nmeans.should eq [100, 200.5, 402.5]
  end
end