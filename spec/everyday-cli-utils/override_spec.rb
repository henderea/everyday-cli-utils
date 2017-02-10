require_relative '../../lib/everyday-cli-utils'
include EverydayCliUtils
import :override

class TestClass
  def test(t)
    "Hi #{t}!"
  end
end

describe 'override' do
  it 'supports overriding methods' do
    arr = [1, 2, 3]
    arr.override(:first) { "Boo! #{self.overrides.first}" }
    expect(arr.first).to eq 'Boo! 1'
  end

  it 'supports overriding methods multiple times' do
    arr = [1, 2, 3]
    arr.override(:first) { "Boo! #{self.overrides.first}" }
    arr.override(:first) { "Boo Again! #{self.overrides[1].first}" }
    arr.override(:first) { "Boo Again Again! #{self.overrides[1].first} | #{self.overrides.first}" }
    expect(arr.has_override?(:first)).to be true
    expect(arr.has_override?(:test)).to be false
    expect(arr.first).to eq 'Boo Again Again! Boo! 1 | Boo Again! 1'
  end

  it 'supports overriding methods multiple times on a class' do
    TestClass.override(:test) { |t| "Boo! #{self.overrides.test("-#{t}-")}" }
    TestClass.override(:test) { |t| "Boo Again! #{self.overrides[1].test("+#{t}+")}" }
    TestClass.override(:test) { |t| "Boo Again Again! #{self.overrides[1].test("!#{t}!")} | #{self.overrides.test("~#{t}~")}" }
    expect(TestClass.has_override?(:first)).to be false
    expect(TestClass.has_override?(:test)).to be true
    expect(TestClass.new.test('Eric')).to eq 'Boo Again Again! Boo! Hi -!Eric!-! | Boo Again! Hi +~Eric~+!'
  end

  it 'supports calling methods defined by Object that do not trigger method_missing' do
    arr = [1, 2, 3]
    arr.override(:inspect) { "Boo! #{self.overrides.call_override :inspect}" }
    arr.override(:inspect) { "Boo Again! #{self.overrides[1].call_override :inspect}" }
    arr.override(:inspect) { "Boo Again Again! #{self.overrides[1].call_override :inspect} | #{self.overrides.call_override :inspect}" }
    expect(arr.inspect).to eq 'Boo Again Again! Boo! [1, 2, 3] | Boo Again! [1, 2, 3]'
  end

  it 'supports calling methods on the overrides object that were not overridden' do
    arr = [1, 2, 3]
    arr.override(:first) { "Boo! #{self.overrides.first}" }
    arr.override(:first) { "Boo Again! #{self.overrides[1].first}" }
    arr.override(:first) { "Boo Again Again! #{self.overrides[1].first} | #{self.overrides.first} || #{self.overrides.last}" }
    expect(arr.first).to eq 'Boo Again Again! Boo! 1 | Boo Again! 1 || 3'
  end
end