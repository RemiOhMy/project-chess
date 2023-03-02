# frozen-string-literal: true

require_relative 'chess_piece'

# Class Pawn to represent the pawn piece in chess
class Pawn < ChessPiece
  attr_accessor :en_passant_able

  def initialize(loc, col, board)
    super(loc, col, board)
    @en_passant_able = false
  end

  def to_s
    color == :black ? '♟︎' : '♙'
  end

  def movesets
    if color == :black
      [1, 0]
    elsif color == :white
      [-1, 0]
    end
  end

  def starting_pos?
    row == case color
           when :black
             1
           else
             6
           end
  end

  def valid_moves
    moves = []

    current_row, current_col = location
    move_row, move_col = movesets
    # one step
    if board[[current_row + move_row, current_col + move_col]].nil? &&
       board.in_bounds?([current_row + move_row, current_col + move_col])
      moves << [current_row + move_row, current_col + move_col]

      # two steps at starting point
      if starting_pos? && board[[current_row + (move_row * 2), current_col + move_col]].nil?
        moves << [current_row + (move_row * 2), current_col + move_col]
      end
    end

    # diagonal for enemies
    # diagonal left
    diag_left = [current_row + move_row, current_col - 1]
    moves << diag_left if board.in_bounds?(diag_left) && enemy?(diag_left)
    # diagonal right
    diag_right = [current_row + move_row, current_col + 1]
    moves << diag_right if board.in_bounds?(diag_right) && enemy?(diag_right)

    moves
  end

  def en_passant_left?
    left_piece = [row, column - 1]
    forward = movesets.first
    left_corner = [row + forward, column - 1]
    if board.in_bounds?(left_piece) &&
       board[left_piece].is_a?(Pawn) &&
       board[left_piece].en_passant_able &&
       board[left_corner].nil?
      true
    else
      false
    end
  end

  def en_passant_right?
    right_piece = [row, column + 1]
    forward = movesets.first
    right_corner = [row + forward, column + 1]
    if board.in_bounds?(right_piece) &&
       board[right_piece].is_a?(Pawn) &&
       board[right_piece].en_passant_able &&
       board[right_corner].nil?
      true
    else
      false
    end
  end
end
