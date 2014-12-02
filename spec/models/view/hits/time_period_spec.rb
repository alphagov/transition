require 'spec_helper'

describe View::Hits::TimePeriod do
  describe '.all' do

    context 'with no arguments' do
      subject(:all_periods) { View::Hits::TimePeriod.all }

      it { should be_an(Array) }
      it { should have(4).periods }

      describe 'the first' do
        subject { View::Hits::TimePeriod.all.first }

        it { should be_a(View::Hits::TimePeriod) }

        its(:title)      { should == 'Yesterday' }
        its(:slug)       { should == 'yesterday' }
        its(:query_slug) { should == 'yesterday' }
      end
    end

    context 'excluding "All time"' do
      subject(:periods_except_all_time) { View::Hits::TimePeriod.all(exclude_all_time: true) }

      it { should have(3).periods }
      it { should_not include(View::Hits::TimePeriod['all-time']) }
    end
  end

  describe 'the default, last-30-days' do
    subject { View::Hits::TimePeriod.default }

    its(:title)      { should == 'Last 30 days' }
    its(:slug)       { should == 'last-30-days' }
    its(:query_slug) { should be_nil }
    its(:no_content) { should == 'in this time period' }
  end

  describe 'indexing on slug' do
    it 'returns nil on unrecognised time periods' do
      View::Hits::TimePeriod['non-existent'].should be_nil
    end

    describe 'All time' do
      subject { View::Hits::TimePeriod['all-time'] }

      its(:title)      { should == 'All time' }
      its(:range)      { should == (100.years.ago.to_date..Date.today) }
      its(:start_date) { should == 100.years.ago.to_date }
      its(:end_date)   { should == Date.today }
      its(:no_content) { should == 'yet' }

      it 'calculates dates correctly even if, say, the server has been up a few decades' do
        Timecop.freeze(Date.new(2112, 10, 31)) do
          View::Hits::TimePeriod['all-time'].range.should == (100.years.ago.to_date..Date.today)
        end
      end
    end

    describe 'Last 30 days' do
      subject { View::Hits::TimePeriod['last-30-days'] }

      its(:title)      { should == 'Last 30 days' }
      its(:range)      { should == (30.days.ago.to_date..Date.today) }
      its(:start_date) { should == 30.days.ago.to_date }
      its(:end_date)   { should == Date.today }
      its(:no_content) { should == 'in this time period' }

      it 'calculates dates correctly even if, say, the server has been up a few decades' do
        Timecop.freeze(Date.new(2112, 10, 31)) do
          View::Hits::TimePeriod['last-30-days'].range.should == (30.days.ago.to_date..Date.today)
        end
      end
    end

    context 'the slug describes a period' do
      context 'A valid period' do
        subject { View::Hits::TimePeriod['20131001-20131031'] }

        its(:start_date)  { should == Date.new(2013, 10, 1) }
        its(:end_date)    { should == Date.new(2013, 10, 31) }
        its(:range)       { should == (Date.new(2013, 10, 1)..Date.new(2013, 10, 31)) }
        its(:title)       { should == '1 Oct 2013 - 31 Oct 2013' }
        its(:slug)        { should == '20131001-20131031' }
        its(:no_content)  { should == 'in this time period' }
        its(:single_day?) { should be_false }
      end

      context 'A valid single date' do
        subject { View::Hits::TimePeriod['20131001'] }

        its(:start_date)  { should == Date.new(2013, 10, 1) }
        its(:end_date)    { should == Date.new(2013, 10, 1) }
        its(:range)       { should == (Date.new(2013, 10, 1)..Date.new(2013, 10, 1)) }
        its(:title)       { should == '1 Oct 2013' }
        its(:slug)        { should == '20131001' }
        its(:no_content)  { should == 'in this time period' }
        its(:single_day?) { should be_true }
      end

      context 'Invalid periods' do
        specify { expect { View::Hits::TimePeriod['99999999'] }.to raise_error(ArgumentError) }
        specify { expect { View::Hits::TimePeriod['99999999-99999999'] }.to raise_error(ArgumentError) }
        specify { expect { View::Hits::TimePeriod['20130101-20120101'] }.to raise_error(ArgumentError) }
      end

    end
  end
end
