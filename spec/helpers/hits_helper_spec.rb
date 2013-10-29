require 'spec_helper'

describe HitsHelper do
  describe '#link_to_hit' do
    let(:hit) { build :hit }
    specify { helper.link_to_hit(hit).should =~ %r(<a href="http://.*example\.gov\.uk/article/123">/article/123</a>) }
  end

  describe '#google_data_table' do
    let(:archives) { [
      build(:hit, hit_on: '2012-12-31', count: 3, http_status: 410),
      build(:hit, hit_on: '2012-12-30', count: 1000, http_status: 410)
    ] }

    let(:errors) { [
      build(:hit, hit_on: '2012-12-31', count: 3, http_status: 404),
      build(:hit, hit_on: '2012-12-30', count: 4, http_status: 404)
    ] }

    let(:redirects) { [
      build(:hit, hit_on: '2012-12-30', count: 4, http_status: 301)
    ] }

    let(:categories) {
      [
        Transition::Hits::Category['archives'].tap { |c| c.points = archives },
        Transition::Hits::Category['errors'].tap { |c| c.points = errors },
        Transition::Hits::Category['redirects'].tap { |c| c.points = redirects }
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
