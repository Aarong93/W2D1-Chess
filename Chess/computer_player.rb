require 'benchmark'

class ComputerPlayer

  COLORS = ["white", "black"]

  def initialize(color)
    @color = color
    @opp_color = @color == COLORS[0] ? "black" : "white"
  end

  def play_turn(board)
    @board = board

    puts Benchmark.measure { @move = find_best_move }

    @move
  end


  private

  def find_best_move
    best_move = nil
    best_eval = nil
    counter = { count: 0 }

    @board.legal_moves_with_start(@color).each do |move|
      save_move(move)
      @board.make_any_move(move[0], move[1])
      cur_node = Node.new(@board, @opp_color, @color)
      cur_eval = -1 * cur_node.alpha_beta(find_depth, -10000, 10000, counter)
      undo_move
      #found mate in one dont check any other moves
      return move if cur_eval == 1000

      if best_move.nil? || cur_eval > best_eval
        best_move = move
        best_eval = cur_eval
      end
    end
    p best_eval
    p "find_move calls #{counter}"

    best_move
  end

  def save_move(move)
    start, end_pos = move
    end_row, end_col = end_pos
    @last_captured = @board.grid[end_row][end_col]
    @reverse_move  = [end_pos, start]
  end

  def undo_move
    @board.make_any_move(@reverse_move[0], @reverse_move[1])
    @board.grid[@reverse_move[0][0]][@reverse_move[0][1]] = @last_captured
  end


  def find_depth
    #search deeper with fewer pieces on board\
    piece_count = 0

    @board.grid.each do |row|
      row.each do |tile|
        piece_count += 1 if tile.class < Piece
      end
    end

    case piece_count
      when piece_count < 5
        return 5
      when piece_count < 6
        return 5
      when piece_count < 8
        return 4
      when piece_count < 10
        return 4
      when piece_count < 16
        return 3
      else
        return 3
    end
  end


end
