class PQueue
  def initialize(buff = [])
    @buff = buff
    
    if @buff.size > 0
      ((buff.size / 2 - 1)..0).each do |n|
        downheoap(n)
      end
    end
  end

  def push(data)
    @buff << data
    upheap(@buff.size - 1)
  end

  def pop
    raise "Index Error" if @buff.size == 0
    
    value = @buff[0]
    last = @buff.pop
    if @buff.size > 0
      @buff[0] = last
      downheap(0)
    end

    return value
  end

  def peek
    raise "Index Error" if @buff.size == 0
    return @buff[0]
  end

  def empty?
    return @buff.size == 0
  end

  private
  def downheap(n)
    size = @buff.size
    while true
      c = 2 * n + 1
      if c >= size
        break
      end

      if c + 1 < size
        if @buff[c] > @buff[c + 1]
          c += 1
        end
      end

      if @buff[n] <= @buff[c]
        break
      end

      tmp = @buff[n]
      @buff[n] = @buff[c]
      @buff[c] = tmp
      n = c
    end
  end

  def upheap(n)
    while true
      p = (n - 1) / 2
      if p < 0 or @buff[p] <= @buff[n]
        break
      end
      tmp = @buff[n]
      @buff[n] = @buff[p]
      @buff[p] = tmp
      n = p
    end
  end
end
