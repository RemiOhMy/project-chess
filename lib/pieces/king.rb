# frozen-string-literal: true

require_relative 'chess_piece'
require_relative 'steppable'

# Class King to represent the king piece in chess
class King < ChessPiece
  include Steppable

  def to_s
    color == :black ? '♚' : '♔'
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

  def short_castle?
    if board[[row, 5]].nil? && board[[row, 6]].nil?
      true
    else
      false
    end
  end

  def long_castle?
    if board[[row, 1]].nil? && board[[row, 2]].nil? && board[[row, 3]].nil?
      true
    else
      false
    end
  end
end
