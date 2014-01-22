module Enumerable
  def removefalse
    select { |i| i }
  end

  def filtermap(&block)
    map(&block).removefalse
  end

  def sum
    reduce(:+)
  end

  def prod
    reduce(:*)
  end

  def average
    sum.to_f / count.to_f
  end

  def std_dev
    avg = average
    cnt = count.to_f
    su  = summap { |v| (v.to_f - avg.to_f) ** 2 }
    Math.sqrt(su / cnt)
  end

  def floats
    map(&:to_f)
  end

  def summap(&block)
    map(&block).sum
  end

  def productmap(&block)
    map(&block).prod
  end

  def chompall
    map(&:chomp)
  end

  def join(join_str)
    map(&:to_s).reduce { |a, b| a << join_str << b }
  end
end