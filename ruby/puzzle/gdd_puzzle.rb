# -*- coding: utf-8 -*-
require 'digest/md5'

class Ctrl
  def initialize(left, right, up, down)
    @@left = left.to_i
    @@right = right.to_i
    @@up = up.to_i
    @@down = down.to_i
  end

  def reduce(str)
    str.split('').each do |c|
      case c
      when 'L'
        @@left -= 1
      when 'R'
        @@right -= 1
      when 'U'
        @@up -= 1
      when 'D'
        @@down -= 1
      end
    end
  end

  def rest
    [@@left, @@right, @@up, @@down]
  end
end

class Puzzle
  FORE = :fore
  BACK = :back

  def initialize(adjacent, goal, width, height, board)
    @width = width.to_i
    @height = height.to_i
    @open = []
    @closed = {}
    @start = nil
    @goal = nil
    @adjacent = adjacent
    @state = 0
    @table = table_new(@width * @height)
 
    b = board_new(board.split(''), 0, '', FORE)
    @open << b
    @start = b

    b = board_new(goal, 0, '', BACK)
    @open << b
    @goal = b
  end

  def board_new(ary, depth, ctrl, dir)
    board = Board.new(ary, depth, ctrl, dir)
    board.calc_eval_func(@width, @height)
    board.calc_invert_dist(@width, @height)
    return board
  end

  def table_new(size)
    table = {}
    i = 1
    j = 1
    (size).times do |n|
      if n < ((@height - 2) * @width)
        if n % @width < @width - 2
          table[n] = n + 1
        elsif n % @width == @width -2
          table[n] = n + 2
        else
          table[n] = 0
        end
      else
        if n < @width * @height - 4 
          if n % 2 == 0
            table[n] = [(@height -2) * @width, i]
            i += 1
          else
            table[n] = [(@height - 1) * @width, j]
            j += 1
          end
        end
      end
    end
    return table
  end

  def insert(board)
    @open << board
  end
  
  def sort
    i = 0
    #if @state < @height - 2
    #  @open = @open.sort_by{|b| [b.id > b.ef ? b.id : b.ef, b.dir, i += 1]}
    #else
      @open = @open.sort_by{|b| b.id > b.ef ? b.id : b.ef}
    #end
  end

  def solve
    limit = @open[0].id > @open[0].ef ? @open[0].id : @open[0].ef
    limit += 2

    threads = []
    while true
      self.sort

      a = @open.shift
      if a.nil?
        a = @start
        @state = 0
        @closed.clear
      end

      depth = a.ctrl.size
      space = a.cell.index('0')
      dir = a.dir
      
      
      while @table[@state] == 0
        @state += 1
      end
      st = @table[@state]

      if a.dir == FORE
        if @state < (@height - 2) * @width
          if a.cell[0, st] == @goal.cell[0, st]
            @state += 1
            @open.delete_if{|b| b.cell[0, st] != @goal.cell[0, st]}
          end
        elsif @state >= (@height - 2) * @width
          if a.cell[st[0], st[1]] == @goal.cell[st[0],  st[1]]
            @state += 1
            @open.delete_if{|b| b.cell[st[0], st[1]] != @goal.cell[st[0], st[1]]}
          end
        end
      end

      @adjacent[space].each do |i|
        if a.dir == FORE and @state < (@height - 2) * @width
          if i < @state
            next
          end
        end

        cell = a.cell.dup
        cell = cell.swap(i, space)

        if i > space
          if i == space + 1
            ctrl = 'R'
            ctrl = 'L' if a.dir == BACK
          else
            ctrl = 'D'
            ctrl = 'U' if a.dir == BACK
          end
        else
          if i == space - 1
            ctrl = 'L'
            ctrl = 'R' if a.dir == BACK
          else
            ctrl = 'U'
            ctrl = 'D' if a.dir == BACK
          end
        end

        safe = true
        case a.ctrl[-1]
        when 'U'
          safe = false if ctrl == 'D'
        when 'D'
          safe = false if ctrl == 'U'
        when 'L'
          safe = false if ctrl == 'R'
        when 'R'
          safe = false if ctrl == 'L'
        end
        
        if @closed.key?(cell)
          c = @closed[cell]

          if dir != c.dir
            if dir == FORE
              return a.ctrl + c.ctrl
            else
              return c.ctrl + a.ctrl
            end
          end
        
        else
          b = board_new(cell, depth + 1, a.ctrl + ctrl, dir)
          low = (b.id > b.ef) ? b.id : b.ef
          
          if limit + 2 >= low and safe
            insert(b)
          end
          @closed[b.cell] = b
        end
      end
      
      @closed[a.cell] = a
      low = (a.id > a.ef) ? a.id : a.ef
      limit = depth + low + 10
    end
  end
    
  def print(cell)
    @height.times do |i|
      p cell[i * @width, @width]
    end
    puts
  end

  class Board
    def initialize(ary, depth = 0, ctrl = '', dir)
      @cell = ary
      @ef = 0
      @id = 0
      @depth = depth
      @ctrl = ctrl
      @dir = dir
    end
    attr_accessor :cell, :ef, :ctrl, :depth, :hash, :id, :dir


    def calc_eval_func(width, height)
      sum = 0
      copy = @cell.dup
      copy.each_index do |i|
        if copy[i] =~ /[A-Z]/
          copy[i] = copy[i].ord - 55
        elsif copy[i] =~ /=/
          copy[i] = i + 1
        else
          copy[i] = copy[i].to_i
        end
        # 横のヒューリスティック関数値
        sum += ( (copy[i] - 1) % width - i % width ).abs

        # 縦のヒューリスティック関数値
        if copy[i] == 0
          now = i / width
          sum += height - now - 1
        else
          sum += ( ((copy[i] - 1) / width).abs - i / width ).abs
        end
      end
      @ef = sum
    end

    def calc_invert_dist(width, height)
      id = 0
      tmp = []
      cell = @cell.dup
      cell.each_index do |i|
        if cell[i] == '='
          cell[i] = (i + 1).to_s
        elsif cell[i] == '0'
          cell[i] = (width * height).to_s
        end
      end

      cell.each_index do |i|
        tmp << cell[i, cell.size].count{|n| cell[i] > n}
      end
      id += tmp.reduce(:+) / width + tmp.reduce(:+) % width

      tmp.clear
      t_cell = []
      height.times do |i|
        t_cell << cell[i * width, width]
      end

      t_cell = t_cell.transpose.flatten
      t_cell.each_index do |i|
        tmp << t_cell[i, t_cell.size].count{|n| t_cell[i] > n}
      end
      id += tmp.reduce(:+) / height + tmp.reduce(:+) % height
      @id = id
    end

  end
end

class Array
  def swap(p1, p2)
    tmp = self[p1]
    self[p1] = self[p2]
    self[p2] = tmp

    return self
  end
end

adjacent = []
open(ARGV[0]) do |f|
  while l = f.gets
    eval l
  end
end

goal = []
open(ARGV[1]) do |f|
  while l = f.gets
    eval l
  end
end

file = ARGV[2]
open(file) do |f|
  l = f.gets
  ctrl = Ctrl.new(*(l.split(' ')))
  t = f.gets.to_i

  t.times do |n|
    l = f.gets.chomp.split(',')

    if ctrl.rest.all?{|n| n > 0}
      if l[0].to_i < 5 and l[1].to_i < 5
        puzzle = Puzzle.new(adjacent[n], goal[n], *l)
        result = puzzle.solve
        puts result
        ctrl.reduce(result)
      else
        print "\n"
      end
    else
      print "\n"
    end
  end
end
