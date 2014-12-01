require 'spec_helper'

describe HitsHelper do

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

    let(:live_site_that_transitioned_on_2012_12_30) do
       site = build(:site, launch_date: Date.new(2012,12,30))
       site.hosts << build(:host, cname: 'redirector-cdn.production.govuk.service.gov.uk')
       site.save
       site
    end

    subject(:array) { helper.google_data_table(categories, live_site_that_transitioned_on_2012_12_30) }

    it { should be_a(String) }
    it { should include('{"label":"Date","type":"date"}') }
    it { should include('{"label":"Archives","type":"number"},{"label":"Errors","type":"number"},{"label":"Redirects","type":"number"}') }
    it { should_not include('nil') }

    describe 'it includes a normal data row' do
      it { should include('{"c":[{"v":"Date(2012, 11, 31)"},{"v":""},{"v":3,"f":"3"},{"v":3,"f":"3"},{"v":0,"f":"0"}]}') }
    end

    describe 'it includes an annotation on the transition date' do
      it { should include('{"c":[{"v":"Date(2012, 11, 30)"},{"v":"Transition"},{"v":1000,"f":"1,000"},{"v":4,"f":"4"},{"v":4,"f":"4"}]}') }
    end
  end

  describe '#current_category_in_period_path' do
    let(:params)     { {} }
    let(:query_slug) { 'yesterday' }
    let(:period) do
      double('TimePeriod').tap do |period|
        period.stub(:query_slug).and_return(query_slug)
      end
    end

    subject(:path) { helper.current_category_in_period_path(period) }

    before do
      helper.stub(:params).and_return(params)
      # stubs @site internal to helper
      helper.class_eval { attr_writer :site }
      helper.site = site
    end

    context 'when a site is present' do
      let(:site) { build :site, abbr: 'site_abbr' }

      context 'when no category is set' do
        it 'defaults to the summary with the period' do
          path.should == '/sites/site_abbr/hits/summary?period=yesterday'
        end
      end

      context 'when a category is set' do
        let(:params) { { category: 'errors' } }
        it 'links to the category and period for the site' do
          path.should == '/sites/site_abbr/hits/category?category=errors&period=yesterday'
        end

        context 'when the time period is default' do
          let(:query_slug) { nil }

          it 'links to the category without the period for the site' do
            path.should == '/sites/site_abbr/hits/category?category=errors'
          end
        end
      end
    end

    context 'when no site is present (universal analytics)' do
      let(:site) { nil }

      it 'links to the universal hits with the period' do
        path.should == '/hits?period=yesterday'
      end

      context 'when a category is set' do
        let(:params) { { category: 'errors' } }
        it 'links to the universal hits with the category and period' do
          path.should == '/hits/category?category=errors&period=yesterday'
        end

        context 'when the time period is default' do
          let(:query_slug) { nil }

          it 'links to the universal hits current category without the period' do
            path.should == '/hits/category?category=errors'
          end
        end
      end
    end
  end
end
