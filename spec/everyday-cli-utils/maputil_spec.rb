require_relative '../../lib/everyday-cli-utils'
include EverydayCliUtils
import :maputil

describe 'maputil' do
  it 'provides a shortcut for removing false values from a list' do
    arr = [0, false, false, 3, 4, false, 6, false, 8, 9]
    expect(arr.removefalse).to eq [0, 3, 4, 6, 8, 9]
  end

  it 'allows a filtered mapping' do
    arr  = (0..9).to_a
    arr2 = arr.filtermap { |v| v % 3 == 0 ? false : v ** 2 }
    expect(arr2).to eq [1, 4, 16, 25, 49, 64]
  end

  it 'provides a shortcut for summing the values of an list' do
    arr = (0..9).to_a
    sum = arr.epg_sum
    expect(sum).to eq 45
  end

  it 'provides a shortcut for calculating the product of the values of an list' do
    arr  = (1..4).to_a
    prod = arr.prod
    expect(prod).to eq 24
  end

  it 'provides a shortcut for calculating the average of the values of an list' do
    arr = (0..9).to_a
    avg = arr.floats.average
    expect(avg).to eq 4.5
  end

  it 'provides a shortcut for calculating the standard deviation of the values of an list' do
    arr     = (0..9).to_a.floats
    std_dev = arr.std_dev
    expect(std_dev).to eq Math.sqrt(8.25)
  end

  it 'provides a shortcut for calculating the sum of a mapped list' do
    arr    = (0..9).to_a
    summap = arr.summap { |v| v ** 2 }
    expect(summap).to eq 285
  end

  it 'provides a shortcut for calculating the product of a mapped list' do
    arr     = (1..4).to_a
    prodmap = arr.productmap { |v| v + 1 }
    expect(prodmap).to eq 120
  end

  it 'provides a shortcut to remove newlines from all strings in a list' do
    arr = (0..9).to_a.map { |v| "#{v}\n" }
    expect(arr).to eq %W(0\n 1\n 2\n 3\n 4\n 5\n 6\n 7\n 8\n 9\n)
    expect(arr.chompall).to eq %w(0 1 2 3 4 5 6 7 8 9)
  end

  it 'provides a shortcut to join elements in a list' do
    list   = ('a'..'f')
    joined = list.join('-')
    expect(joined).to eq 'a-b-c-d-e-f'
  end

  it 'provides a shortcut for making hashes with multiple keys that have the same value' do
    hash     = { [:a, :b, :c, :d] => '1-4', :e => '5' }
    expanded = hash.expand
    expected = { a: '1-4', b: '1-4', c: '1-4', d: '1-4', :e => '5' }
    expect(expanded).to eq expected
  end

  it 'provides a means of cloning a hash' do
    hash   = { a: 1, b: 2, c: 3, d: 4, e: 5 }
    cloned = hash.clone
    expect(hash).to_not equal cloned
  end

  it 'provides a means of using map with a hash' do
    hash     = { a: 1, b: 2, c: 3, d: 4, e: 5, f: 6 }
    mapped   = hash.hashmap { |v| v[1] + ((v[0] == :a || v[0] == :c || v[0] == :e) ? 1 : -1) }
    expected = { a: 2, b: 1, c: 4, d: 3, e: 6, f: 5 }
    expect(mapped).to eq expected
  end

  it 'provides a means of extending one hash with another' do
    hash1    = { a: 1, b: 2, c: 3, d: 4, e: 5, f: 6 }
    hash2    = { a: 11, d: 14, f: 16 }
    extended = hash2.extend_hash(hash1)
    expected = { a: 11, b: 2, c: 3, d: 14, e: 5, f: 16 }
    expect(extended).to eq expected
  end

  it 'provides a means of subtracting one hash from another' do
    hash1    = { a: 1, b: 2, c: 3, d: 4, e: 5, f: 6 }
    hash2    = { a: 1, d: 14, f: 6 }
    diff = hash1 - hash2
    expected = { b: 2, c: 3, d: 4, e: 5 }
    expect(diff).to eq expected
  end
end