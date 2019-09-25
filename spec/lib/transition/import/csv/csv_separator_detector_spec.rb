require "spec_helper"
require "transition/import/csv/csv_separator_detector"

describe Transition::Import::CSV::CSVSeparatorDetector do
  def make_a_detector(rows)
    Transition::Import::CSV::CSVSeparatorDetector.new(rows)
  end

  describe "#separator_count" do
    it "should be 1 when there is only one row with one separator" do
      detector = make_a_detector(["/a,"])
      expect(detector.separator_count(",")).to eq(1)
    end

    it "should be 1 when only one of two rows has the separator" do
      detector = make_a_detector(["/a", "/b,TNA"])
      expect(detector.separator_count(",")).to eq(1)
    end

    it "ignores other separators and only counts the given one" do
      detector = make_a_detector(["/a\tTNA", "/b,TNA", "/c,", "/d,"])
      expect(detector.separator_count(",")).to eq(3)
    end
  end

  describe "#separator" do
    context "when there are more commas than tabs in the rows" do
      it "is comma" do
        detector = make_a_detector(["/a\tTNA", "/b,TNA", "/c,", "/d,"])
        expect(detector.separator).to eq(",")
      end
    end

    context "when there are more tabs than commas in the rows" do
      it "is tab" do
        detector = make_a_detector(["/a\tTNA", "/b,\tTNA", "/c\t", "/d,"])
        expect(detector.separator).to eq("\t")
      end
    end

    context "when there are equal numbers of tabs and commas" do
      it "is tab" do
        detector = make_a_detector(["/a\tTNA", "/b\tTNA", "/c,", "/d,"])
        expect(detector.separator).to eq("\t")
      end
    end
  end
end
