# frozen-string-literal: true

require_relative 'chess_piece'
require_relative 'steppable'

# Class Knight to represent the knight piece in chess
class Knight < ChessPiece
  include Steppable
  def to_s
    color == :black ? '♞' : '♘'
  end

  def movesets
    [
      [-2, 1],
      [-1, 2],
      [1, 2],
      [2, 1],
      [2, -1],
      [1, -2],
      [-1, -2],
      [-2, -1]
    ]
  end
end