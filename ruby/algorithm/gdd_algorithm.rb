class Node
  def initialize(nums, depth = 0)
    @nums = nums
    @depth = depth
    @left = nil
    @right = nil
  end
  attr_accessor :nums, :depth, :left, :right
end

class Tree
  require "digest/md5"

  def initialize(nums)
    @root = nil
    @states = []
    @root = node_new(nums)
    create_tree(@root, 0)
  end
  attr_accessor :root

  def node_new(nums, depth = 0)
    @states << hash(nums)
    Node.new(nums, depth)
  end

  def create_tree(node, depth)
    unless node.nums == [] or node.nums.nil?
      div = div2(node.nums)
      del = del5(node.nums)

      if !(@states.include?(div))
        node.left = node_new(div, depth + 1)
        create_tree(node.left, depth + 1)
      end

      if !(@states.include?(del))
        node.right = node_new(del, depth + 1)
        create_tree(node.right, depth + 1)
      end
    end
  end

  def min_depth
    nodes = get_nodes(@root)
    node = nodes.min_by{|node| node.depth}
    node.depth
  end

  private
  def div2(nums)
    if nums.all?{|n| n == 0}
      return nil
    else
      nums.map{|n| n / 2}
    end
  end

  def del5(nums)
    copy = nums.dup
    ary = copy.delete_if{|n| n % 5 == 0}
    if nums == ary
      return nil
    else
      return ary
    end
  end

  def hash(nums)
    Digest::MD5.digest(nums.to_s)
  end

  def get_nodes(node)
    if node.left.nil? and node.right.nil? and node.nums == []
      return [node]
    else
      if !node.left.nil? and !node.right.nil?
        get_nodes(node.left) + get_nodes(node.right)

      elsif !node.left.nil? and node.right.nil?
        get_nodes(node.left) + []

      elsif !node.right.nil? and node.left.nil?
        [] + get_nodes(node.right)
      else
        return []
      end
    end
  end
end

file = ARGV[0]

open(file) do |f|
  l = f.gets
  t = l.to_i

  t.times do
    size = f.gets.chomp
    nums = f.gets.chomp.split(' ').map{|n| n.to_i}

    tree = Tree.new(nums)
    p tree.min_depth
  end
end
