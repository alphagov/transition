require 'spec_helper'

describe Transition::Import::CSV::CSVSeparatorDetector do
  def make_a_detector(rows)
    Transition::Import::CSV::CSVSeparatorDetector.new(rows)
  end

  describe '#separator_count' do
    it 'should be 1 when there is only one row with one separator' do
      detector = make_a_detector(['/a,'])
      detector.separator_count(',').should == 1
    end

    it 'should be 1 when only one of two rows has the separator' do
      detector = make_a_detector(['/a', '/b,TNA'])
      detector.separator_count(',').should == 1
    end

    it 'ignores other separators and only counts the given one' do
      detector = make_a_detector(["/a\tTNA", '/b,TNA', '/c,', '/d,'])
      detector.separator_count(',').should == 3
    end
  end

  describe '#separator' do
    context 'when there are more commas than tabs in the rows' do
      it 'is comma' do
        detector = make_a_detector(["/a\tTNA", '/b,TNA', '/c,', '/d,'])
        detector.separator.should == ','
      end
    end

    context 'when there are more tabs than commas in the rows' do
      it 'is tab' do
        detector = make_a_detector(["/a\tTNA", "/b,\tTNA", "/c\t", '/d,'])
        detector.separator.should == "\t"
      end
    end

    context 'when there are equal numbers of tabs and commas' do
      it 'is tab' do
        detector = make_a_detector(["/a\tTNA", "/b\tTNA", '/c,', '/d,'])
        detector.separator.should == "\t"
      end
    end
  end
end
