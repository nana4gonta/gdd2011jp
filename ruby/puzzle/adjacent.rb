def create_adjacent(ary, width, height)
  adjacent = []
  ary.each_index do |i|
    tmp = []

    if ary[i] == '='
      tmp << nil
      adjacent << tmp
      next
    end

    # up
    if i - width >= 0 and ary[i - width] != '='
      tmp << i - width
    end

    # left
    if i % width > 0 and ary[i - 1] != '='
      tmp << i - 1
    end

    # right
    if i % width < width - 1 and ary[i + 1] != '='
      tmp << i + 1
    end

    # down
    if i + width < width * height and ary[i + width] != '='
      tmp << i + width
    end

    adjacent << tmp
  end

  return adjacent
end

file = ARGV[0]
open(file) do |f|
  l = f.gets
  t = f.gets.to_i

  t.times do
    l = f.gets.chomp.split(',')
    width = l[0].to_i
    height = l[1].to_i
    start = l[2].split('')
    adjacent = create_adjacent(start, width, height)

    puts "adjacent << #{adjacent.to_s}"
  end
end
