# frozen-string-literal: true

require_relative 'save_file'

# Class Game to handle game mechanics
class Game
  attr_accessor :player_one, :player_two, :current_player, :board, :display

  # hash to translate row input into the respective integer value
  ROW_INPUTS = {
    '1' => 7,
    '2' => 6,
    '3' => 5,
    '4' => 4,
    '5' => 3,
    '6' => 2,
    '7' => 1,
    '8' => 0
  }.freeze

  def initialize(board, player_one, player_two, display)
    @board = board
    @player_one = player_one
    @player_two = player_two
    @display = display
    @current_player = @player_one
    @file = SaveFile.new
  end

  def play
    until game_over?
      # show board and turn status
      display.clear
      display.show_board
      puts "#{current_player.name}'s turn!"

      # clear ally pawns of en_passant_vulnerability
      toggle_ally_en_passant

      # check for checkmate/stalement/check
      puts 'You are currently in check!' if board.in_check?(current_player.color)

      # prompt player for their initial choice
      # either to select a piece or to save/resign from the game
      start_pos = initial_choice

      # if save or forfeit, run the respective functions
      case start_pos
      when 'save'
        @file.save_game(self)
        break
      when 'forfeit'
        forfeit = true
        display_result(forfeit)
        break
      end
      # prompt player for movement choice
      # either to select a valid location or to do a special move (en passant or castling)
      movement_choice(start_pos)

      # switch players
      switch_player
    end
    display_result if game_over?
  end

  def load
    file = @file.load_game
    @board = file.data[:board]
    @player_one = file.data[:player_one]
    @player_two = file.data[:player_two]
    @display = file.data[:display]
    @current_player = file.data[:current_player]

    play
  end

  def checkmate?(color)
    ally_pieces = board.get_pieces.select { |piece| piece.color == color }

    ally_pieces.all? { |piece| piece.safe_moves.empty? }
  end

  def stalemate?(color)
    checkmate?(color) && !board.in_check?(color)
  end

  def game_over?
    checkmate?(current_player.color) || stalemate?(current_player.color)
  end

  def display_result(forfeit = false)
    other_player = current_player == player_one ? player_two : player_one

    if stalemate?(current_player.color)
      puts "The game is a stalemate! It's a draw!"
    elsif checkmate?(current_player.color)
      puts "#{other_player.name} has checkmated #{current_player.name}! #{other_player.name} wins!"
    elsif forfeit
      puts "#{current_player.name} has forfeited! #{other_player.name} wins!"
    end
  end

  def initial_choice
    puts 'Select a piece to move OR [S - save] [F - Forfeit]'
    # get input and initially check if its S/F
    choice = gets.chomp
    case choice.to_s.upcase
    when 'S'
      'save'
    when 'F'
      'forfeit'
    else
      # otherwise proceed to process choice
      validate_piece(chess_notation_to_coordinates(choice))
    end
  rescue InvalidMoveError => e
    puts e.message
    retry
  end

  def movement_choice(start_pos)
    puts 'Select the location to move to: '
    # check piece first if it can castle (king needs to be chosen)
    # or if it can do an en passant (chosen pawn vs en_passant_able pawn)
    if board.can_castle?(start_pos)
      castle_possible_movement(start_pos)
    elsif board.can_en_passant?(start_pos)
      en_passant_possible_movement(start_pos)
    else
      choice = gets.chomp
      end_pos = chess_notation_to_coordinates(choice)
      board.execute_move(start_pos, end_pos)
    end
  rescue InvalidMoveError => e
    puts e.message
    retry
  end

  def castle_possible_movement(start_pos)
    puts 'Castling is currently valid:'
    puts '[S - Short Castling]' if board[start_pos].short_castle?
    puts '[L - Long Castling]' if board[start_pos].long_castle?

    choice = gets.chomp

    if choice.to_s.upcase == 'S' && board[start_pos].short_castle?
      board.execute_castling(start_pos, 'short')
    elsif choice.to_s.upcase == 'L' && board[start_pos].long_castle?
      board.execute_castling(start_pos, 'long')
    else
      end_pos = chess_notation_to_coordinates(choice)
      board.execute_move(start_pos, end_pos)
    end
  end

  def en_passant_possible_movement(start_pos)
    puts 'En passant is currently valid:'
    puts '[L - Leftward En Passant]' if board[start_pos].en_passant_left?
    puts '[R - Rightward En Passant]' if board[start_pos].en_passant_right?

    choice = gets.chomp

    if choice.to_s.upcase == 'L' && board[start_pos].en_passant_left?
      board.execute_en_passant(start_pos, 'left')
    elsif choice.to_s.upcase == 'R' && board[start_pos].en_passant_right?
      board.execute_en_passant(start_pos, 'right')
    else
      end_pos = chess_notation_to_coordinates(choice)
      board.execute_move(start_pos, end_pos)
    end
  end

  # convert letter/number input into [num, num] array
  def chess_notation_to_coordinates(choice)
    raise InvalidMoveError, 'Entered empty string, please try again!' if choice.empty?

    input = choice.upcase.split('')

    if input.length > 2 || !input[0].ord.between?(65, 72) || !input[1].to_i.between?(1, 8)
      raise InvalidMoveError, 'Incorrect input format - please give the column and row with no spaces. [e.g. A2, B6]'
    end

    [ROW_INPUTS[input[1]], input[0].ord - 65]
  end

  def switch_player
    @current_player = @current_player == @player_one ? @player_two : @player_one
  end

  # set en passant vulnerability of all ally pawns to false
  def toggle_ally_en_passant
    ally_pawns = board.get_pieces.select { |piece| current_player.color == piece.color && piece.is_a?(Pawn) }

    ally_pawns.each { |piece| piece.en_passant_able = false }
  end

  def validate_piece(loc)
    # check if the location given has a piece
    if board[loc].nil?
      raise InvalidMoveError, "Location #{loc} is empty!"
    # if its the same color as player
    elsif board[loc].color != current_player.color
      raise InvalidMoveError,
            "Piece color at #{loc} is #{board[loc].color} but current player color is #{current_player.color}!"
    # and if the piece has any actual valid moves
    # check if their only valid move is en passant
    elsif board[loc].safe_moves.empty? && !(board[loc].is_a?(Pawn) && board.can_en_passant?(loc))
      raise InvalidMoveError, "Piece at #{loc} has no valid moves!"
    end

    # return loc if it is valid
    loc
  end
end
