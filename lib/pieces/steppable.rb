# frozen-string-literal: true

# Module Steppable to get valid moves of pieces that have static steps
module Steppable
  def valid_moves
    moves = []

    movesets.each do |(move_row, move_col)|
      current_row, current_col = location

      current_row += move_row
      current_col += move_col
      loc = [current_row, current_col]

      next unless board.in_bounds?(loc)

      if board[loc].nil?
        moves << loc
      elsif enemy?(loc)
        moves << loc
        next
      else
        next
      end
    end

    moves
  end
end
