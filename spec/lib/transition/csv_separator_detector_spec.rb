require 'spec_helper'

describe Transition::CSVSeparatorDetector do
  let(:detector) { Transition::CSVSeparatorDetector.new(rows) }

  describe '#separator_count' do
    context 'when there is only one row with one separator' do
      let(:rows) { ['/a,'] }
      specify    { detector.separator_count(',').should == 1 }
    end

    context 'when only one of two rows has the separator' do
      let(:rows) { ['/a', '/b,TNA'] }
      specify    { detector.separator_count(',').should == 1 }
    end

    context 'when there are other separators' do
      let(:rows) { ["/a\tTNA", '/b,TNA', '/c,', '/d,'] }

      it 'ignores them and only counts the majority separator' do
        detector.separator_count(',').should == 3
      end
    end
  end

  describe '#separator' do
    subject { detector.separator }

    context 'when there are more commas than tabs in the rows' do
      let(:rows)       { ["/a\tTNA", '/b,TNA', '/c,', '/d,'] }
      it('is a comma') { should == ',' }
    end

    context 'when there are more tabs than commas in the rows' do
      let(:rows)     { ["/a\tTNA", "/b,\tTNA", "/c\t", '/d,'] }
      it('is a tab') { should == "\t" }
    end

    context 'when there are equal numbers of tabs and commas' do
      let(:rows)     { ["/a\tTNA", "/b\tTNA", '/c,', '/d,'] }
      it('is a tab') { should == "\t" }
    end
  end
end
