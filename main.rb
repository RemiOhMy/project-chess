# frozen-string-literal: true

require_relative './lib/board'
require_relative './lib/board_display'
require_relative './lib/game'
require_relative './lib/invalid_move_error'
require_relative './lib/pieces'
require_relative './lib/player'

puts 'Welcome to Chess!'
print 'Would you like to [1] start a new game or [2] load a save?'

choice = nil

begin
  choice = gets.chomp
  p choice
  raise 'Please enter 1 OR 2' if choice != '1' && choice != '2'
rescue StandardError => e
  puts e.message
  retry
end

b = Board.start_chess

t = BoardDisplay.new(b)

p1 = Player.new('Player One', :white)
p2 = Player.new('Player Two', :black)

g = Game.new(b, p1, p2, t)

if choice == '1'
  g.play
elsif choice == '2'
  g.load
end
