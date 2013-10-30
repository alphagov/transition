require 'spec_helper'

describe Transition::Hits::Category do
  describe '.all' do
    subject(:all_categories) { Transition::Hits::Category.all }

    it { should be_an(Array) }
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
      it 'errors on unrecognised categories' do
        expect { Transition::Hits::Category['non-existent'] }.to raise_error(ArgumentError)
      end

      subject(:others_category) { Transition::Hits::Category['other'] }

      its(:title)  { should == 'Other' }
      its(:to_sym) { should == :other }
      its(:color)  { should == '#aaa' }
      its(:plural) { should == 'others' }

      describe 'the polyfill of points when points= is called' do
        context 'valid data' do
          let(:others) do
            [
              build(:hit, hit_on: '2012-12-28', count: 1000, http_status: 200),
              build(:hit, hit_on: '2012-12-31', count: 3, http_status: 200)
            ]
          end

          before { others_category.points = others }

          it { should have(4).points }

          its(:'points.first') { should == others.first }
          its(:'points.last')  { should == others.last }

          describe 'the first inserted hit' do
            subject { others_category.points[1] }

            its(:hit_on) { should eql(Date.new(2012, 12, 29)) }
            its(:count) { should eql(0) }
          end
        end

        context 'invalid data - more than one row per date' do
          let(:others) do
            [
              build(:hit, hit_on: '2012-12-28', count: 1000, http_status: 200),
              build(:hit, hit_on: '2012-12-28', count: 3, http_status: 200)
            ]
          end

          it 'raises an error' do
            expect { others_category.points = others }.to raise_error(ArgumentError)
          end
        end
      end

    end
  end
end
