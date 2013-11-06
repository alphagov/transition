require 'spec_helper'

describe HitsHelper do
  describe '#link_to_hit' do
    let(:hit) { build :hit }
    specify { helper.link_to_hit(hit).should =~ %r(<a href="http://.*example\.gov\.uk/article/123">/article/123</a>) }
  end

  describe '#any_totals_for' do
    let(:all_cats)  { View::Hits::Category.all }
    let(:some_totals) { all_cats.map { |cat| cat.tap {|c| c.points = [build(:daily_hit_total)] } } }
    let(:no_totals)   { all_cats.map { |cat| cat.tap {|c| c.points = [] } } }

    context 'there are totals' do
      it 'is true' do
        helper.any_totals_for?(some_totals).should be_true
      end
    end

    context 'there are no totals' do
      it 'is false' do
        helper.any_totals_for?(no_totals).should be_false
      end

      it 'is false' do
        helper.any_totals_for?(nil).should be_false
      end
    end
  end

  describe '#google_data_table' do
    let(:archives) { [
      build(:daily_hit_total, total_on: '2012-12-31', count: 3, http_status: 410),
      build(:daily_hit_total, total_on: '2012-12-30', count: 1000, http_status: 410)
    ] }

    let(:errors) { [
      build(:daily_hit_total, total_on: '2012-12-31', count: 3, http_status: 404),
      build(:daily_hit_total, total_on: '2012-12-30', count: 4, http_status: 404)
    ] }

    let(:redirects) { [
      build(:daily_hit_total, total_on: '2012-12-30', count: 4, http_status: 301)
    ] }

    let(:categories) {
      [
        View::Hits::Category['archives'].tap { |c| c.points = archives },
        View::Hits::Category['errors'].tap { |c| c.points = errors },
        View::Hits::Category['redirects'].tap { |c| c.points = redirects }
      ]
    }

    subject(:array) { helper.google_data_table(categories) }

    it { should be_a(String) }
    it { should include('{"label":"Date","type":"date"}') }
    it { should include('{"label":"Archives","type":"number"},{"label":"Errors","type":"number"},{"label":"Redirects","type":"number"}') }
    it { should include('{"c":[{"v":"Date(2012, 11, 31)"},{"v":3,"f":"3"},{"v":3,"f":"3"},{"v":0,"f":"0"}]}') }
    it { should include('{"c":[{"v":"Date(2012, 11, 30)"},{"v":1000,"f":"1,000"},{"v":4,"f":"4"},{"v":4,"f":"4"}]}') }
    it { should_not include('nil') }
  end
end
