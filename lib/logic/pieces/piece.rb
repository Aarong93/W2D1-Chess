class Piece
  attr_reader :color
  attr_accessor :selected, :curr_pos, :board, :can_castle, :has_castled

  def initialize(color, board, curr_pos, options)
    @color, @board, @curr_pos, @selected = color, board, curr_pos, false
    @can_castle = options["can_castle"];
    @has_castled = options["has_castled"]
  end

  def moves(board)
    raise StandardError.message("child should overwrite")
  end

  def to_s
    raise StandardError.message("child should overwrite")
  end

  def legal_moves(board)
    all_moves = moves(board)

    all_moves.reject do |move|
      save_move(move)
      @castle = false
      @queened = false
      special_move = @board.make_any_move(@curr_pos, move)
      @queened = special_move == "queened"
      @k_castled = special_move == "k_castled"
      @q_castled = special_move == "q_castled"
      flag = @board.in_check?(color)
      undo_move

      #makes sure not castling through or out of check
      flag = castle_check if @k_castled || @q_castled

      flag
    end
  end


  def dup(new_board)
    self.class.new(color, new_board, curr_pos)
  end


  private

  def save_move(end_pos)
    @disabled_castling = false
    end_row, end_col = end_pos
    @last_captured = @board.grid[end_row][end_col]
    @reverse_move  = [end_pos, @curr_pos]
    @disabled_castling = true if self.can_castle
  end

  def undo_move(ignore_castle = false)
    @board[@reverse_move[1]] = self
    @curr_pos = @reverse_move[1]
    @board.grid[@reverse_move[0][0]][@reverse_move[0][1]] = @last_captured
    if @queened
      @board[@reverse_move[1]] = Pawn.new(@color, @board, @reverse_move[1])
    end
    unless ignore_castle
      if @k_castled
        @has_castled = false
        @board.make_any_move([@curr_pos[0], @curr_pos[1] + 1], [@curr_pos[0], @curr_pos[1] + 3])
        @board[[@curr_pos[0], @curr_pos[1] + 3]].can_castle = true
      end
      if @q_castled
        @has_castled = false
        @board.make_any_move([@curr_pos[0], @curr_pos[1] - 1], [@curr_pos[0], @curr_pos[1] - 4])
        @board[[@curr_pos[0], @curr_pos[1] - 4]].can_castle = true
      end
    end

    @can_castle = true if @disabled_castling
  end

  def castle_check
    flag = false
    return true if board.in_check?(color)

    if @k_castled
     one_right = [@curr_pos[0], @curr_pos[1] + 1]
     save_move(one_right)
     @board.make_any_move(@curr_pos, one_right)
     flag = @board.in_check?(color)
     undo_move(true)
     return flag
    end

    if @q_castled
      one_left = [@curr_pos[0], @curr_pos[1] - 1]
      save_move(one_left)
      @board.make_any_move(@curr_pos, one_left)
      flag = @board.in_check?(color)
      undo_move(true)
      return flag
    end
  end


end
