# frozen-string-literal: true

require_relative 'chess_piece'
require_relative 'slideable'

# Class Queen to represent the queen piece in chess
class Queen < ChessPiece
  include Slideable

  def to_s
    color == :black ? '♛' : '♕'
  end

  def movesets
    [
      [0, 1],
      [0, -1],
      [1, 0],
      [-1, 0],
      [-1, -1],
      [-1, 1],
      [1, 1],
      [1, -1]
    ]
  end
end
