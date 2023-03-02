# frozen-string-literal: true

require_relative 'chess_piece'
require_relative 'slideable'

# Class Bishop to represent the bishop piece in chess
class Bishop < ChessPiece
  include Slideable

  def to_s
    color == :black ? '♝' : '♗'
  end

  def movesets
    [
      [-1, -1],
      [-1, 1],
      [1, 1],
      [1, -1]
    ]
  end
end
