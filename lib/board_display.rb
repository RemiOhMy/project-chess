# frozen-string-literal: true

# Class BoardDisplay to render the board into the command-line
class BoardDisplay
  attr_accessor :board

  def initialize(board)
    @board = board
  end

  def clear
    if Gem.win_platform?
      system 'cls'
    else
      system 'clear'
    end
  end

  def show_board
    puts '╔ A B C D E F G H ╗'
    (1..8).reverse_each.with_index do |index, row|
      print "#{index} "
      8.times do |col|
        if board[[row, col]].nil?
          print '- '
        else
          print "#{board[[row, col]]} "
        end
      end
      puts "#{row + 1}"
    end
    puts '╚ A B C D E F G H ╝'
  end
end
