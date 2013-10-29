require 'spec_helper'

describe Transition::Hits::Category do
  describe '.all' do
    subject(:all_categories) { Transition::Hits::Category.all }

    it { should be_an(Array)}
    it { should have(5).categories }

    describe 'the first' do
      subject { Transition::Hits::Category.all.first }

      it { should be_a(Transition::Hits::Category) }

      its(:title)  { should == 'All hits' }
      its(:to_sym) { should == :all }
      its(:color)  { should == '#333' }
      its(:plural) { should == 'hits' }
    end

    describe 'indexing' do
      subject(:errors_category) { Transition::Hits::Category['errors'] }

      its(:title)  { should == 'Errors' }
      its(:to_sym) { should == :errors }
      its(:color)  { should == '#e99' }
      its(:plural) { should == 'errors' }

      describe 'the polyfill of points when points= is called' do
        let(:errors) do
          [
            build(:hit, hit_on: '2012-12-28', count: 1000, http_status: 404),
            build(:hit, hit_on: '2012-12-31', count: 3, http_status: 404)
          ]
        end

        before { errors_category.points = errors }

        it { should have(4).points }

        its(:'points.first') { should == errors.first }
        its(:'points.last')  { should == errors.last }

        describe 'the first inserted hit' do
          subject { errors_category.points[1] }

          its(:hit_on) { should eql(Date.new(2012,12,29)) }
          its(:count)  { should eql(0) }
        end
      end

    end
  end
end
