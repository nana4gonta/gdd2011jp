def create_goal(ary)
  wall = []
  ary.count('=').times do
    index = ary.find_index{|c| c == '='}
    wall << index
  end

  copy = ary.dup
  copy.each_index do |i|
    if copy[i] == '='
      copy[i] = (i + 1)
    elsif copy[i] =~ /[A-Z]/
      copy[i] = copy[i].ord - 55
    else
      copy[i] = copy[i].to_i
    end
  end

  copy = copy.sort
  wall.each do |n|
    copy[n] = '='
  end

  copy = copy.map{|c| if c == '=' then c elsif c >= 9 then (c + 56).chr else (c + 1).to_s end}
  goal = copy
  goal[-1] = '0'

  return goal
end

file = ARGV[0]
open(file) do |f|
  l = f.gets
  t = f.gets.to_i

  t.times do
    l = f.gets.chomp.split(',')
    start = l[2].split('')
    goal = create_goal(start)
    puts "goal << #{goal.to_s}"
  end
end
