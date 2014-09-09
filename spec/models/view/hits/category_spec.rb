require 'spec_helper'

describe View::Hits::Category do
  describe '.all' do
    subject(:all_categories) { View::Hits::Category.all }

    it { should be_an(Array) }
    it { should have(4).categories }

    describe 'the first' do
      subject(:all_category) { View::Hits::Category.all.first }

      it { should be_a(View::Hits::Category) }

      its(:title)              { should == 'All hits' }
      its(:to_sym)             { should == :all }
      its(:color)              { should == '#333' }
      its(:plural)             { should == 'hits' }
    end

    describe 'indexing' do
      it 'errors on unrecognised categories' do
        expect { View::Hits::Category['non-existent'] }.to raise_error(ArgumentError)
      end

      subject(:errors_category) { View::Hits::Category['errors'] }

      its(:title)       { should == 'Errors' }
      its(:to_sym)      { should == :errors }
      its(:color)       { should == '#e99' }
      its(:plural)      { should == 'errors' }

      describe 'the polyfill of points when points= is called' do
        context 'valid data' do
          let(:errors) do
            [
              build(:daily_hit_total, total_on: '2012-12-28', count: 1000, http_status: 404),
              build(:daily_hit_total, total_on: '2012-12-31', count: 3, http_status: 404)
            ]
          end

          before { errors_category.points = errors }

          it { should have(4).points }

          its(:'points.first') { should == errors.first }
          its(:'points.last')  { should == errors.last }

          describe 'the first inserted total' do
            subject { errors_category.points[1] }

            its(:total_on) { should eql(Date.new(2012, 12, 29)) }
            its(:count) { should eql(0) }
          end
        end

        context 'invalid data - more than one row per date' do
          let(:errors) do
            [
              build(:daily_hit_total, total_on: '2012-12-28', count: 1000, http_status: 200),
              build(:daily_hit_total, total_on: '2012-12-28', count: 3, http_status: 200)
            ]
          end

          it 'raises an error' do
            expect { errors_category.points = errors }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
