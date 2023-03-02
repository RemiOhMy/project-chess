# frozen-string-literal: true

require 'yaml'

# class SaveFile to handle file management (saving and loading)
class SaveFile
  attr_accessor :data

  def initialize
    @data = {
      board: nil,
      player_one: nil,
      player_two: nil,
      display: nil,
      current_player: nil
    }
  end

  def save_game(game)
    data[:board] = game.board
    data[:player_one] = game.player_one
    data[:player_two] = game.player_two
    data[:display] = game.display
    data[:current_player] = game.current_player

    save_file
  end

  def save_file
    print 'Please enter a name for your saved file: '

    name = gets.chomp

    name = '1' if name.nil?
    name = "saves/#{name}.yml"

    save = self

    Dir.mkdir('saves') unless Dir.exist?('saves')

    file = File.open(name, 'w')

    file.puts YAML.dump(save)

    puts "Save File #{name} created!"
  end

  def load_game
    begin
      print 'Please enter the name of your saved file: '

      name = gets.chomp
      name = "saves/#{name}.yml"

      raise "File #{name} not found!" unless File.exist?(name)
    rescue StandardError => e
      puts e
      retry
    end
    save_file = File.open(name, 'r')
    file = YAML.safe_load(save_file, aliases: true, permitted_classes: [
                            SaveFile, Symbol, Board, BoardDisplay, Game, Player, Bishop, ChessPiece, King, Knight, Pawn, Queen, Rook
                          ])
    save_file.close
    file
  end

  def load_file(file)
    data[:board] = file[:board]
    data[:player_one] = file[:player_one]
    data[:player_two] = file[:player_two]
    data[:display] = file[:display]
    data[:current_player] = file[:current_player]

    data
  end
end
