require_relative '../../lib/everyday-cli-utils/maputil'

describe 'maputil' do
  it 'provides a shortcut for removing false values from a list' do
    arr = [0, false, false, 3, 4, false, 6, false, 8, 9]
    arr.removefalse.should eq [0, 3, 4, 6, 8, 9]
  end

  it 'allows a filtered mapping' do
    arr  = (0..9).to_a
    arr2 = arr.filtermap { |v| v % 3 == 0 ? false : v ** 2 }
    arr2.should eq [1, 4, 16, 25, 49, 64]
  end

  it 'provides a shortcut for summing the values of an list' do
    arr = (0..9).to_a
    sum = arr.sum
    sum.should eq 45
  end

  it 'provides a shortcut for calculating the product of the values of an list' do
    arr  = (1..4).to_a
    prod = arr.prod
    prod.should eq 24
  end

  it 'provides a shortcut for calculating the average of the values of an list' do
    arr = (0..9).to_a
    avg = arr.floats.average
    avg.should eq 4.5
  end

  it 'provides a shortcut for calculating the standard deviation of the values of an list' do
    arr     = (0..9).to_a.floats
    std_dev = arr.std_dev
    std_dev.should eq Math.sqrt(8.25)
  end

  it 'provides a shortcut for calculating the sum of a mapped list' do
    arr    = (0..9).to_a
    summap = arr.summap { |v| v ** 2 }
    summap.should eq 285
  end

  it 'provides a shortcut for calculating the product of a mapped list' do
    arr     = (1..4).to_a
    prodmap = arr.productmap { |v| v + 1 }
    prodmap.should eq 120
  end

  it 'provides a shortcut to remove newlines from all strings in a list' do
    arr = (0..9).to_a.map { |v| "#{v}\n" }
    arr.should eq %W(0\n 1\n 2\n 3\n 4\n 5\n 6\n 7\n 8\n 9\n)
    arr.chompall.should eq %w(0 1 2 3 4 5 6 7 8 9)
  end

  it 'provides a shortcut to join elements in a list' do
    list   = ('a'..'f')
    joined = list.join('-')
    joined.should eq 'a-b-c-d-e-f'
  end
end