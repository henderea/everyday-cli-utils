require_relative 'safe/maputil'

module Enumerable
  def removefalse
    EverydayCliUtils::MapUtil.removefalse(self)
  end

  def filtermap(&block)
    EverydayCliUtils::MapUtil.filtermap(self, &block)
  end

  def sum
    EverydayCliUtils::MapUtil.sum(self)
  end

  def prod
    EverydayCliUtils::MapUtil.prod(self)
  end

  def average
    EverydayCliUtils::MapUtil.average(self)
  end

  def std_dev
    EverydayCliUtils::MapUtil.std_dev(self)
  end

  def floats
    EverydayCliUtils::MapUtil.floats(self)
  end

  def summap(&block)
    EverydayCliUtils::MapUtil.summap(self, &block)
  end

  def productmap(&block)
    EverydayCliUtils::MapUtil.productmap(self, &block)
  end

  def chompall
    EverydayCliUtils::MapUtil.chompall(self)
  end

  def join(join_str)
    EverydayCliUtils::MapUtil.join(self, join_str)
  end
end

class Hash
  def expand
    EverydayCliUtils::MapUtil.expand(self)
  end

  def clone
    EverydayCliUtils::MapUtil.clone_hash(self)
  end

  def hashmap(&block)
    EverydayCliUtils::MapUtil.hashmap(self, &block);
  end

  def extend_hash(base_hash)
    EverydayCliUtils::MapUtil.extend_hash(base_hash, self)
  end

  def -(hash2)
    EverydayCliUtils::MapUtil.hash_diff(self, hash2)
  end
end