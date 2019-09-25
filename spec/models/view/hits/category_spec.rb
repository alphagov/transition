require "rails_helper"

describe View::Hits::Category do
  describe ".all" do
    subject(:all_categories) { View::Hits::Category.all }

    it { is_expected.to be_an(Array) }
    it "has 4 categories" do
      expect(subject.size).to eq(4)
    end

    describe "the first" do
      subject(:all_category) { View::Hits::Category.all.first }

      it { is_expected.to be_a(View::Hits::Category) }

      describe "#title" do
        subject { super().title }
        it { is_expected.to eq("All hits") }
      end

      describe "#to_sym" do
        subject { super().to_sym }
        it { is_expected.to eq(:all) }
      end

      describe "#color" do
        subject { super().color }
        it { is_expected.to eq("#333") }
      end

      describe "#plural" do
        subject { super().plural }
        it { is_expected.to eq("hits") }
      end
    end

    describe "indexing" do
      it "errors on unrecognised categories" do
        expect { View::Hits::Category["non-existent"] }.to raise_error(ArgumentError)
      end

      subject(:errors_category) { View::Hits::Category["errors"] }

      describe "#title" do
        subject { super().title }
        it { is_expected.to eq("Errors") }
      end

      describe "#to_sym" do
        subject { super().to_sym }
        it { is_expected.to eq(:errors) }
      end

      describe "#color" do
        subject { super().color }
        it { is_expected.to eq("#e99") }
      end

      describe "#plural" do
        subject { super().plural }
        it { is_expected.to eq("errors") }
      end

      describe "the polyfill of points when points= is called" do
        context "valid data" do
          let(:errors) do
            [
              build(:daily_hit_total, total_on: "2012-12-28", count: 1000, http_status: 404),
              build(:daily_hit_total, total_on: "2012-12-31", count: 3, http_status: 404),
            ]
          end

          before { errors_category.points = errors }

          it "has 4 points" do
            expect(subject.points.size).to eq(4)
          end

          describe "#points" do
            subject { super().points }
            describe "#first" do
              subject { super().first }
              it { is_expected.to eq(errors.first) }
            end
          end

          describe "#points" do
            subject { super().points }
            describe "#last" do
              subject { super().last }
              it { is_expected.to eq(errors.last) }
            end
          end

          describe "the first inserted total" do
            subject { errors_category.points[1] }

            describe "#total_on" do
              subject { super().total_on }
              it { is_expected.to eql(Date.new(2012, 12, 29)) }
            end

            describe "#count" do
              subject { super().count }
              it { is_expected.to eql(0) }
            end
          end
        end

        context "invalid data - more than one row per date" do
          let(:errors) do
            [
              build(:daily_hit_total, total_on: "2012-12-28", count: 1000, http_status: 200),
              build(:daily_hit_total, total_on: "2012-12-28", count: 3, http_status: 200),
            ]
          end

          it "raises an error" do
            expect { errors_category.points = errors }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
