require "rails_helper"

describe View::Hits::TimePeriod do
  describe ".all" do
    context "with no arguments" do
      subject(:all_periods) { View::Hits::TimePeriod.all }

      it { is_expected.to be_an(Array) }
      it "has 4 periods" do
        expect(subject.size).to eq(4)
      end

      describe "the first" do
        subject { View::Hits::TimePeriod.all.first }

        it { is_expected.to be_a(View::Hits::TimePeriod) }

        describe "#title" do
          subject { super().title }
          it { is_expected.to eq("Yesterday") }
        end

        describe "#slug" do
          subject { super().slug }
          it { is_expected.to eq("yesterday") }
        end

        describe "#query_slug" do
          subject { super().query_slug }
          it { is_expected.to eq("yesterday") }
        end
      end
    end

    context 'excluding "All time"' do
      subject(:periods_except_all_time) { View::Hits::TimePeriod.all(exclude_all_time: true) }

      it "has 3 periods" do
        expect(subject.size).to eq(3)
      end
      it { is_expected.not_to include(View::Hits::TimePeriod["all-time"]) }
    end
  end

  describe "the default, last-30-days" do
    subject { View::Hits::TimePeriod.default }

    describe "#title" do
      subject { super().title }
      it { is_expected.to eq("Last 30 days") }
    end

    describe "#slug" do
      subject { super().slug }
      it { is_expected.to eq("last-30-days") }
    end

    describe "#query_slug" do
      subject { super().query_slug }
      it { is_expected.to be_nil }
    end

    describe "#no_content" do
      subject { super().no_content }
      it { is_expected.to eq("in this time period") }
    end
  end

  describe "indexing on slug" do
    it "returns nil on unrecognised time periods" do
      expect(View::Hits::TimePeriod["non-existent"]).to be_nil
    end

    describe "All time" do
      subject { View::Hits::TimePeriod["all-time"] }

      describe "#title" do
        subject { super().title }
        it { is_expected.to eq("All time") }
      end

      describe "#range" do
        subject { super().range }
        it { is_expected.to eq(100.years.ago.to_date..Time.zone.today) }
      end

      describe "#start_date" do
        subject { super().start_date }
        it { is_expected.to eq(100.years.ago.to_date) }
      end

      describe "#end_date" do
        subject { super().end_date }
        it { is_expected.to eq(Time.zone.today) }
      end

      describe "#no_content" do
        subject { super().no_content }
        it { is_expected.to eq("yet") }
      end

      it "calculates dates correctly even if, say, the server has been up a few decades" do
        Timecop.freeze(Date.new(2112, 10, 31)) do
          expect(View::Hits::TimePeriod["all-time"].range).to eq(100.years.ago.to_date..Time.zone.today)
        end
      end
    end

    describe "Last 30 days" do
      subject { View::Hits::TimePeriod["last-30-days"] }

      describe "#title" do
        subject { super().title }
        it { is_expected.to eq("Last 30 days") }
      end

      describe "#range" do
        subject { super().range }
        it { is_expected.to eq(30.days.ago.to_date..Time.zone.today) }
      end

      describe "#start_date" do
        subject { super().start_date }
        it { is_expected.to eq(30.days.ago.to_date) }
      end

      describe "#end_date" do
        subject { super().end_date }
        it { is_expected.to eq(Time.zone.today) }
      end

      describe "#no_content" do
        subject { super().no_content }
        it { is_expected.to eq("in this time period") }
      end

      it "calculates dates correctly even if, say, the server has been up a few decades" do
        Timecop.freeze(Date.new(2112, 10, 31)) do
          expect(View::Hits::TimePeriod["last-30-days"].range).to eq(30.days.ago.to_date..Time.zone.today)
        end
      end
    end

    context "the slug describes a period" do
      context "A valid period" do
        subject { View::Hits::TimePeriod["20131001-20131031"] }

        describe "#start_date" do
          subject { super().start_date }
          it { is_expected.to eq(Date.new(2013, 10, 1)) }
        end

        describe "#end_date" do
          subject { super().end_date }
          it { is_expected.to eq(Date.new(2013, 10, 31)) }
        end

        describe "#range" do
          subject { super().range }
          it { is_expected.to eq(Date.new(2013, 10, 1)..Date.new(2013, 10, 31)) }
        end

        describe "#title" do
          subject { super().title }
          it { is_expected.to eq("1 Oct 2013 - 31 Oct 2013") }
        end

        describe "#slug" do
          subject { super().slug }
          it { is_expected.to eq("20131001-20131031") }
        end

        describe "#no_content" do
          subject { super().no_content }
          it { is_expected.to eq("in this time period") }
        end

        describe "#single_day?" do
          subject { super().single_day? }
          it { is_expected.to be_falsey }
        end
      end

      context "A valid single date" do
        subject { View::Hits::TimePeriod["20131001"] }

        describe "#start_date" do
          subject { super().start_date }
          it { is_expected.to eq(Date.new(2013, 10, 1)) }
        end

        describe "#end_date" do
          subject { super().end_date }
          it { is_expected.to eq(Date.new(2013, 10, 1)) }
        end

        describe "#range" do
          subject { super().range }
          it { is_expected.to eq(Date.new(2013, 10, 1)..Date.new(2013, 10, 1)) }
        end

        describe "#title" do
          subject { super().title }
          it { is_expected.to eq("1 Oct 2013") }
        end

        describe "#slug" do
          subject { super().slug }
          it { is_expected.to eq("20131001") }
        end

        describe "#no_content" do
          subject { super().no_content }
          it { is_expected.to eq("in this time period") }
        end

        describe "#single_day?" do
          subject { super().single_day? }
          it { is_expected.to be_truthy }
        end
      end

      context "Invalid periods" do
        specify { expect { View::Hits::TimePeriod["99999999"] }.to raise_error(ArgumentError) }
        specify { expect { View::Hits::TimePeriod["99999999-99999999"] }.to raise_error(ArgumentError) }
        specify { expect { View::Hits::TimePeriod["20130101-20120101"] }.to raise_error(ArgumentError) }
      end
    end
  end
end
