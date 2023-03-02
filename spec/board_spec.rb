# frozen-string-literal: true

require_relative '../lib/board'

describe Board do
  let(:board) { Board.new }
  describe '#get_pieces' do
    it 'will flatten the grid array and return all non-nil values' do
      board[[1, 1]] = 'apple'
      board[[3, 1]] = 'orange'
      result = board.get_pieces
      expect(result).to eq(%w[apple orange])
    end
  end

  describe '#in_bounds?' do
    context 'if the row is out of bounds' do
      it 'will return false' do
        row_out = [8, 0]
        result = board.in_bounds?(row_out)
        expect(result).to be false
      end
    end
    context 'if the column is out of bounds' do
      it 'will return false' do
        col_out = [0, 8]
        result = board.in_bounds?(col_out)
        expect(result).to be false
      end
    end
    context 'if the row and column are in bounds' do
      it 'will return true' do
        in_bounds = [3, 3]
        result = board.in_bounds?(in_bounds)
        expect(result).to be true
      end
    end
  end

  describe '#in_check?' do
    context 'when the white player is in check' do
      it 'will return true'
    end
  end
end
