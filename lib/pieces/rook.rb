# frozen-string-literal: true

require_relative 'chess_piece'
require_relative 'slideable'

# Class Rook to represent the rook piece in chess
class Rook < ChessPiece
  include Slideable

  def to_s
    color == :black ? '♜' : '♖'
  end

  def movesets
    [
      [0, 1],
      [0, -1],
      [1, 0],
      [-1, 0]
    ]
  end
end
