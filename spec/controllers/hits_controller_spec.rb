require 'spec_helper'
require 'transition/import/daily_hit_totals'

describe HitsController do
  describe '#category' do
    let(:site) do
      create :site do |site|
        site.hosts << create(:host, hostname: 'alias.gov.uk', site: site)
      end
    end

    let(:host)       { site.default_host }
    let(:host_alias) { site.hosts.last }

    let!(:errors) do
      [
        create(:hit, host: host, hit_on: '2012-12-28', count: 1, http_status: '404'),
        create(:hit, host: host, hit_on: '2012-12-31', count: 1, http_status: '404')
      ]
    end
    let!(:archives) do
      [
       create(:hit, host: host, hit_on: '2012-12-28', count: 2, http_status: '410'),
       create(:hit, host: host, hit_on: '2012-12-31', count: 2, http_status: '410'),
       create(:hit, host: host_alias, hit_on: '2012-12-31', count: 2, http_status: '410')
      ]
    end

    before do
      Timecop.freeze(Date.new(2013, 01, 01))
      login_as_stub_user
      Transition::Import::DailyHitTotals.from_hits!
      get :category, site_id: site, category: test_category_name
    end

    subject(:category)      { assigns[:category] }
    let(:sum_of_hit_counts) { category.points.inject(0) { |sum, hit| sum + hit.count } }

    context 'a single-status category, errors' do
      let(:test_category_name) { 'errors' }

      it 'has one point per day' do
        category.should have(4).points
      end
      it 'adds up to two total errors' do
        sum_of_hit_counts.should == 2
      end
    end

    context 'a multi-status category, archives' do
      let(:test_category_name) { 'archives' }

      it 'has one point per day' do
        category.should have(4).points
      end
      it 'adds up to eight total archives' do
        sum_of_hit_counts.should == 6
      end
      it 'groups hits by path and status' do
        results = category.hits.map {|r| [r.http_status, r.path, r.count]}
        results.should == [
          ['410', '/article/123', 6]
        ]
        category.hits.length.should == 1
      end
    end
  end
end
