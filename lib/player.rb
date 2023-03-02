# frozen-string-literal: true

# Class Player to hold player information
class Player
  attr_reader :name, :color

  def initialize(name, color)
    @name = name
    @color = color
  end
end
