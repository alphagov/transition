require 'spec_helper'
require 'transition/import/daily_hit_totals'

describe Transition::Import::DailyHitTotals do
  describe '.from_hits!' do
    context 'a single import from a file with no suggested/archive URLs', testing_before_all: true do

      before :all do
        @halloween = Date.new(2013, 10, 31)
        @first_of_nov = Date.new(2013, 11, 1)
        @host = create(:host)
        @hits = [
                  create(:hit, host: @host, path: '/1', count: 10, http_status: '404', hit_on: @halloween),
                  create(:hit, host: @host, path: '/2', count: 10, http_status: '404', hit_on: @halloween),
                  create(:hit, host: @host, path: '/3', count: 10, http_status: '404', hit_on: @halloween),
                  create(:hit, host: @host, path: '/1', count: 10, http_status: '301', hit_on: @first_of_nov),
                  create(:hit, host: @host, path: '/1', count: 10, http_status: '404', hit_on: @first_of_nov)
                ]
        @previous_total = create(:daily_hit_total, host: @host,
                            http_status: '404', total_on: @halloween,
                            count: 13)
        2.times { Transition::Import::DailyHitTotals.from_hits! }
      end

      it 'has imported one total for the 404s, '\
         'two for the other statuses on the next day' do
        DailyHitTotal.count.should == 3
      end

      describe 'The DailyHitTotal for the three halloween 404s' do
        subject(:total) do
          DailyHitTotal.where(total_on: @halloween, http_status: '404').first
        end

        its(:host)        { should eql(@host) }
        its(:http_status) { should eql('404') }
        its(:total_on)    { should eql(@halloween) }

        it 'has overwritten the previous total of 13' do
          total.count.should                  eql(30)
          @previous_total.reload.count.should eql(30)
        end
      end

      it 'has two totals for separate statuses on 1/11' do
        DailyHitTotal.where(total_on: @first_of_nov).should have(2).totals
      end
    end
  end
end
