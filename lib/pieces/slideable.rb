# frozen-string-literal: true

# Module Slideable to get valid moves of pieces that slide
module Slideable
  def valid_moves
    moves = []

    movesets.each do |(move_row, move_col)|
      current_row, current_col = location

      loop do
        current_row += move_row
        current_col += move_col
        loc = [current_row, current_col]

        break unless board.in_bounds?(loc)

        if board[loc].nil?
          moves << loc
        elsif enemy?(loc)
          moves << loc
          break
        else
          break
        end
      end
    end

    moves
  end
end
