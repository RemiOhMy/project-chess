# frozen-string-literal: true

# Parent class for chess pieces
class ChessPiece
  # pass on a reference of the board to determine valid moves for the children pieces
  attr_accessor :location, :color, :board, :has_moved

  def initialize(location, color, board)
    @location = location
    @color = color
    @board = board
    @has_moved = false
  end

  def row
    location.first
  end

  def column
    location.last
  end

  def enemy?(loc)
    !board[loc].nil? && board[loc].color != color
  end

  def safe_moves
    # get all valid moves and reject any move that puts king in check
    valid_moves.reject { |move| board.test_move(location, move, color) }
  end
end
