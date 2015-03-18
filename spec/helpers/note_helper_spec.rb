require 'rails_helper'

describe NoteHelper do
  describe '.clean_content' do
    def helper_method content
      NoteHelper.clean_content content
    end

    it 'transform multiple line break to normal style' do
      expect(helper_method "aaa\n\n\nbbb").to eq "aaa\n\nbbb"
      expect(helper_method "aaa\r\n\r\n\r\nbbb").to eq "aaa\n\nbbb"
      expect(helper_method "aaa\n\r\n\nbbb").to eq "aaa\n\nbbb"
      expect(helper_method "aaa\r\n\n\r\nbbb").to eq "aaa\n\nbbb"
    end

    it 'clean single line break' do
      expect(helper_method "aaa\n\n\nbbb\nccc").to eq "aaa\n\nbbbccc"
      expect(helper_method "aaa\n\n\nbbb\r\nccc").to eq "aaa\n\nbbbccc"
    end

    it 'clean line break at the end of content' do
      expect(helper_method "aaa\n\n\nbbb\n\n\n\n").to eq "aaa\n\nbbb"
      expect(helper_method "aaa\n\n\nbbb\r\n\r\n").to eq "aaa\n\nbbb"
      expect(helper_method "aaa\n\n\nbbb\n\r\n\n").to eq "aaa\n\nbbb"
      expect(helper_method "aaa\n\n\nbbb\r\n\n\r\n").to eq "aaa\n\nbbb"
    end
  end
end
