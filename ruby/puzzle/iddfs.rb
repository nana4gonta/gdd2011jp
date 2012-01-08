def id_lower_search(board, goal, adjacent, dt, limit, move, space, lower)
  if move == limit
    if board == goal
      $count += 1
      print $move_piece[1, $move_piece.size]
      return
    end
  else
    adjacent[space].each do |i|
      p = board[i]
      q = board[i]
      if q =~ /[A-Z]/
        q = q.ord - 55
      elsif q =~ /(=|0)/ 
        
      else
        q = q.to_i
      end

      board[space] = p
      board[i] = '0'
      $move_piece[move + 1] = p

      new_lower = lower - dt[q][i] + dt[q][space]
      if new_lower + move <= limit
        id_lower_search(board, goal, adjacent, dt, limit, move + 1, i, new_lower)
      end

      board[space] = '0'
      board[i] = p
    end
  end
end

def iddfs(board, goal, adjacent, width, height)
  dt = distance_table(board, width)
  n = get_distance(board, dt)
  
  $count = 0
  $move_piece = []
  (n..1000).each do |i|
    id_lower_search(board, goal, adjacent, dt, i, 0, board.index('0'), n)
    break if $count > 0
  end
end
