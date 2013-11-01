require 'spec_helper'

describe View::Hits::TimePeriod do
  describe '.all' do
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

    describe 'the default, all-time' do
      subject { View::Hits::TimePeriod.default }

      its(:title)      { should == 'All time' }
      its(:slug)       { should == 'all-time' }
      its(:query_slug) { should be_nil }
      its(:no_content) { should == 'yet' }
    end

    describe 'indexing on slug' do
      it 'returns nil on unrecognised time periods' do
        View::Hits::TimePeriod['non-existent'].should be_nil
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
    end
  end
end
