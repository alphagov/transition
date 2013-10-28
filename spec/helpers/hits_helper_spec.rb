require 'spec_helper'

describe HitsHelper do
  describe '#link_to_hit' do
    let(:hit) { build :hit }
    specify { helper.link_to_hit(hit).should =~ %r(<a href="http://.*example\.gov\.uk/article/123">/article/123</a>) }
  end

  describe '#raw_summary_array' do
    let(:archives) { [
      build(:hit, hit_on: '2012-12-31', count: 3, http_status: 410),
      build(:hit, hit_on: '2012-12-30', count: 4, http_status: 410)
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

    subject(:array) { helper.raw_summary_array(categories) }

    it { should be_a(String) }
    it { should include('["Date", "Archives", "Errors", "Redirects"]') }
    it { should include('["2012-12-31", 3, 3, 0]') }
    it { should include('["2012-12-30", 4, 4, 4]') }
    it { should_not include('nil') }
  end
end
