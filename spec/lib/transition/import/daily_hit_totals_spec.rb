require 'spec_helper'
require 'transition/import/daily_hit_totals'

describe Transition::Import::DailyHitTotals do
  describe '.from_hits!' do
    context 'a single import from a file with no suggested/archive URLs', testing_before_all: true do

      before :all do
        @halloween = Date.new(2013, 10, 31)
        @host = create(:host)
        @hits = [
                  create(:hit, host: @host, path: '/1', count: 10, http_status: 404, hit_on: @halloween),
                  create(:hit, host: @host, path: '/2', count: 10, http_status: 404, hit_on: @halloween),
                  create(:hit, host: @host, path: '/3', count: 10, http_status: 404, hit_on: @halloween),
                  create(:hit, host: @host, path: '/1', count: 10, http_status: 301, hit_on: Date.new(2013, 11, 1)),
                  create(:hit, host: @host, path: '/1', count: 10, http_status: 404, hit_on: Date.new(2013, 11, 1))
                ]
        @previous_total = create(:daily_hit_total, host: @host,
                            http_status: 404, total_on: @halloween,
                            count: 13)
        2.times { Transition::Import::DailyHitTotals.from_hits! }
      end

      it 'has imported totals' do
        DailyHitTotal.count.should == 3
      end

      describe 'Halloween 404s' do
        subject(:total) do
          DailyHitTotal.where(total_on: @halloween, http_status: 404).first
        end

        its(:http_status) { should eql('404') }
        its(:total_on)    { should eql(@halloween) }
        its(:count)       { should eql(30) }
        its(:host)        { should eql(@host) }
      end

      it 'has two total for separate statuses on 1/11' do
        DailyHitTotal.where(total_on: Date.new(2013, 11, 1)).should have(2).totals
      end
    end
  end
end
