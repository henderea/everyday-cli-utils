module EverydayCliUtils
  module MapUtil
    def self.removefalse(collection)
      collection.select { |i| i }
    end

    def self.filtermap(collection, &block)
      removefalse(collection.map(&block))
    end

    def self.sum(collection)
      collection.reduce(:+)
    end

    def self.prod(collection)
      collection.reduce(:*)
    end

    def self.average(collection)
      sum(collection).to_f / collection.count.to_f
    end

    def self.std_dev(collection)
      avg = average(collection)
      cnt = collection.count.to_f
      su  = summap(collection) { |v| (v.to_f - avg.to_f) ** 2 }
      Math.sqrt(su / cnt)
    end

    def self.floats(collection)
      collection.map(&:to_f)
    end

    def self.summap(collection, &block)
      sum(collection.map(&block))
    end

    def self.productmap(collection, &block)
      prod(collection.map(&block))
    end

    def self.chompall(collection)
      collection.map(&:chomp)
    end

    def self.join(collection, join_str)
      collection.map(&:to_s).reduce { |a, b| a << join_str << b }
    end

    def self.expand(hash)
      rval = {}
      hash.each { |v|
        if v[0].is_a? Array
          v[0].each { |v2| rval[v2] = v[1] }
        else
          rval[v[0]] = v[1]
        end
      }
      rval
    end

    def self.hashmap(hash, &block)
      new_hash = {}
      block_given? ? hash.each { |v| new_hash[v[0]] = block.call(v) } : hash.each { |v| new_hash[v[0]] = v[1] } unless hash.nil?
      new_hash
    end

    def self.clone_hash(hash)
      hashmap(hash)
    end

    def self.extend_hash(base_hash, extending_hash)
      result_hash = clone_hash(extending_hash)
      base_hash.each { |v| result_hash[v[0]] = v[1] unless result_hash.has_key?(v[0]) }
      result_hash
    end

    def self.hash_diff(hash1, hash2)
      new_hash = {}
      hash1.keys.each { |k| new_hash[k] = hash1[k] unless hash2.has_key?(k) && hash1[k] == hash2[k] }
      new_hash
    end
  end
end