# frozen-string-literal: true

require_relative 'pieces'

# Class Board will represent the chess board that will be played on - will keep track of all pieces on the board
class Board
  attr_accessor :grid

  def initialize
    @grid = Array.new(8) { Array.new(8) }
  end

  PROMOTION_UNITS = {
    1 => Queen,
    2 => Rook,
    3 => Knight,
    4 => Bishop
  }.freeze

  # factory function to create a new instance and prepare the board
  def self.start_chess
    board = new

    # set up chess pieces
    8.times do |y|
      loc_black = [1, y]
      board[loc_black] = Pawn.new(loc_black, :black, board)
      loc_white = [6, y]
      board[loc_white] = Pawn.new(loc_white, :white, board)
    end

    [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook].each_with_index do |chess_piece, column|
      [[0, :black], [7, :white]].each do |(row, color)|
        location = [row, column]
        board[location] = chess_piece.new(location, color, board)
      end
    end

    board
  end

  def []=(location, piece)
    row, col = location
    grid[row][col] = piece
  end

  def [](location)
    row, col = location
    grid[row][col]
  end

  def execute_move(start_pos, end_pos)
    # validate end pos
    piece = self[start_pos]
    unless piece.safe_moves.include?(end_pos)
      raise InvalidMoveError, "End position #{start_pos} not in valid movelist: #{piece.safe_moves}"
    end

    # remove piece from board at start
    self[start_pos] = nil

    # place piece from start to end
    self[end_pos] = piece

    # update piece internal loc w/ end
    piece.location = end_pos
    piece.has_moved = true

    # check if pawn
    # then check if they made a double step (to toggle en passant vulnerability) OR if they're up for promotion
    return unless piece.is_a?(Pawn)

    pawn_specials(start_pos, end_pos, piece)
  end

  def get_pieces
    grid.flatten.reject { |piece| piece.nil? }
  end

  def in_bounds?(loc)
    row, col = loc
    row.between?(0, 7) && col.between?(0, 7)
  end

  def in_check?(color)
    king = get_pieces.find { |piece| piece.color == color && piece.is_a?(King) }

    # loop through all safe moves of the enemy, so that checking the king doesnt put them in check either
    get_pieces.select { |piece| piece.color != color }.each do |piece|
      return true if piece.valid_moves.include?(king.location)
    end

    false
  end

  def test_move(start_pos, end_pos, color)
    start_piece = self[start_pos]
    end_piece = self[end_pos]

    # execute the move and see if it puts player's own king in check
    self[start_pos] = nil
    self[end_pos] = start_piece
    start_piece.location = end_pos

    check = in_check?(color)

    # revert the move
    self[end_pos] = end_piece
    self[start_pos] = start_piece
    start_piece.location = start_pos

    # return check result
    check
  end

  ## special moves

  def can_castle?(loc)
    piece = self[loc]
    row = piece.row
    # check if piece is a king and has not moved
    return false unless piece.is_a?(King) && !piece.has_moved

    # check if the pieces at rook location have not moved
    return false if self[[row, 0]].has_moved || self[[row, 7]].has_moved

    # check if castling is possible
    piece.short_castle? || piece.long_castle?
  end

  def execute_castling(loc, type)
    king = self[loc]
    rook = type == 'short' ? self[[king.row, 7]] : self[[king.row, 0]]

    raise 'King/Rook Error!' if !king.is_a?(King) || !rook.is_a?(Rook)

    if type == 'short'
      king_new_loc = [king.row, king.column + 2]
      rook_new_loc = [rook.row, rook.column - 2]
    elsif type == 'long'
      king_new_loc = [king.row, king.column - 2]
      rook_new_loc = [rook.row, rook.column + 3]
    else
      raise 'Type given is not "short" OR "long"!'
    end

    self[loc] = nil
    self[king_new_loc] = king
    king.has_moved = true
    king.location = king_new_loc

    self[rook.location] = nil
    self[rook_new_loc] = rook
    rook.has_moved = true
    rook.location = rook_new_loc
  end

  def pawn_specials(start_pos, end_pos, piece)
    if (piece.color == :white && piece.row == 0) || (piece.color == :black && piece.row == 7)
      promote_pawn(end_pos)
    elsif (piece.color == :white && piece.row == 4 && start_pos[0] == 6) ||
          (piece.color == :black && piece.row == 3 && start_pos[0] == 1)
      piece.en_passant_able = true
    end
  end

  def can_en_passant?(loc)
    piece = self[loc]

    return false unless piece.is_a?(Pawn)

    # check if en passant is possible
    # split these into two just like castling to be able to make two options in game
    # in the case that the pawn has two en passant choices
    piece.en_passant_left? || piece.en_passant_right?
  end

  def execute_en_passant(loc, type)
    pawn = self[loc]

    raise 'Pawn Error' unless pawn.is_a?(Pawn)

    if type == 'left'
      vulnerable_piece = [pawn.row, pawn.column - 1]
      forward = pawn.movesets.first
      corner = [pawn.row + forward, pawn.column - 1]
    elsif type == 'right'
      vulnerable_piece = [pawn.row, pawn.column + 1]
      forward = pawn.movesets.first
      corner = [pawn.row + forward, pawn.column + 1]
    else
      raise 'Type given is not "left" or "right"!'
    end

    self[loc] = nil
    self[vulnerable_piece] = nil
    self[corner] = pawn
    pawn.location = corner
  end

  def promote_pawn(loc)
    puts 'Promote pawn to which unit: [1 - Queen] [2 - Rook] [3 - Knight] [4 - Bishop]'
    choice = 0
    choice = gets.chomp.to_i until choice.between?(1, 4)

    self[loc] = PROMOTION_UNITS[choice].new(loc, self[loc].color, self)
  end
end
