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

  def product
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

  def aand
    if count == 0
      true
    else
      all? { |i| i }
    end
  end

  def aor
    if count == 0
      false
    else
      any? { |i| i }
    end
  end

  def summap(&block)
    map(&block).sum
  end

  def productmap(&block)
    map(&block).product
  end

  def andmap(&block)
    map(&block).aand
  end

  def ormap(&block)
    map(&block).aor
  end

  def chompall
    map(&:chomp)
  end

  def join(join_str)
    map(&:to_s).reduce { |a, b| a << join_str << b }
  end
end