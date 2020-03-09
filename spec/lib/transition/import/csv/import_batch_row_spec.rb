require "rails_helper"
require "transition/import/csv/import_batch_row"

describe Transition::Import::CSV::ImportBatchRow do
  def make_a_row(old_value, new_value = nil)
    line_number = 1
    Transition::Import::CSV::ImportBatchRow.new(site, line_number, [old_value, new_value])
  end

  def make_a_row_with_line_number(line_number, old_value, new_value = nil)
    Transition::Import::CSV::ImportBatchRow.new(site, line_number, [old_value, new_value])
  end

  let(:site) { build :site, query_params: "significant" }

  describe "initializer" do
    it "should strip leading and trailing whitespace" do
      row = make_a_row(" a ", " b\t")
      expect(row.old_value).to eq("a")
      expect(row.new_value).to eq("b")
    end

    it "should strip the old value" do
      row = make_a_row("  ", nil)
      expect(row.old_value).to eql("")
    end

    it "should turn a blank new value to nil" do
      row = make_a_row("", " \t")
      expect(row.new_value).to be_nil
    end
  end

  describe "ignorable?" do
    it "is true for all rows which we can't or wont't use" do
      [
        make_a_row("old URL", "new URL"),
        make_a_row("random", "sentence"),
        make_a_row("oops/missed/a/slash", nil),
        make_a_row("http://homepage.com", nil),
      ].each do |row|
        expect(row.ignorable?).to be_truthy
      end
    end

    it "is false for rows which we want to use" do
      row = make_a_row(" /a", nil)
      expect(row.ignorable?).to be_falsey
    end
  end

  describe "data_row?" do
    it "rejects random headings" do
      row = make_a_row("   URLs   ", nil)
      expect(row.data_row?).to be_falsey
    end

    it "accepts rows with leading whitespace" do
      row = make_a_row(" /a", nil)
      expect(row.data_row?).to be_truthy
    end

    it "accepts rows with http/https scheme" do
      row = make_a_row(" http://", nil)
      expect(row.data_row?).to be_truthy
    end
  end

  describe "type" do
    it 'should be an archive if the new_value is "TNA"' do
      row = make_a_row("", "TNA")
      expect(row.type).to eq("archive")
    end

    it 'should be an archive regardless of the case of "TNA"' do
      row = make_a_row("", "tNa")
      expect(row.type).to eq("archive")
    end

    it 'should not be an archive when the new URL contains "TNA"' do
      row = make_a_row("", "http://a.com/antna")
      expect(row.type).to eq("redirect")
    end

    it "should be an archive when the new URL is a TNA URL" do
      row = make_a_row("", "http://webarchive.nationalarchives.gov.uk/*/http://a.gov.uk")
      expect(row.type).to eq("archive")
    end

    it "should not raise an error when the new URL is unparseable" do
      row = make_a_row("", "http://}")
      # let the ImportBatch validate and report that it isn't parseable as a New URL
      expect(row.type).to eq("redirect")
    end

    it "should be unresolved when the new URL is blank" do
      row = make_a_row("", " ")
      expect(row.type).to eq("unresolved")
    end
  end

  describe "path" do
    context "the old value is empty" do
      it "should keep the path as just a path" do
        row = make_a_row("", nil)
        expect(row.path).to eq("")
      end
    end

    context "the old value is just a path" do
      it "should keep the path as just a path" do
        row = make_a_row("/old", nil)
        expect(row.path).to eq("/old")
      end
    end

    context "the old value is an absolute URL" do
      it "should set the path to just the path" do
        row = make_a_row("http://foo.com/old", nil)
        expect(row.path).to eq("/old")
      end
    end

    describe "canonicalization" do
      it "should canonicalize the path" do
        row = make_a_row("http://foo.com/old?significant=keep&insignificant=drop", nil)
        expect(row.path).to eq("/old?significant=keep")
      end
    end
  end

  describe "new_url" do
    it "should return the new_value if it is a redirect" do
      row = make_a_row("", "http://a.com")
      expect(row.new_url).to eq("http://a.com")
    end

    it "should return nil if it is not a redirect" do
      row = make_a_row("", "TNA")
      expect(row.new_url).to be_nil
    end
  end

  describe "#archive_url" do
    context "with a custom archive URL" do
      let(:archive_url) { "http://webarchive.nationalarchives.gov.uk/*/http://a.com" }
      let(:row) { make_a_row("", archive_url) }

      it "returns the custom URL" do
        expect(row.archive_url).to eq(archive_url)
      end
    end

    context "for a regular archive mapping" do
      let(:row) { make_a_row("", "TNA") }

      it "returns nil" do
        expect(row.archive_url).to be_nil
      end
    end
  end

  describe "<=> - comparison for being able to sort mappings for the same Old URL" do
    let(:redirect)       { make_a_row("/old", "https://a.gov.uk/new") }
    let(:later_redirect) { make_a_row_with_line_number(2, "/old", "https://a.gov.uk/later") }
    let(:archive)        { make_a_row("/old", "TNA") }
    let(:later_archive)  { make_a_row_with_line_number(2, "/old", "TNA") }
    let(:unresolved)     { make_a_row("/old") }

    let(:archive_url)           { "http://webarchive.nationalarchives.gov.uk/*/http://a.com" }
    let(:custom_archive)        { make_a_row("/old", archive_url) }
    let(:later_custom_archive)  { make_a_row_with_line_number(2, "/old", archive_url) }

    context "comparing rows for different paths" do
      it "raises an error" do
        different_path = make_a_row("/different")
        expect { redirect > different_path }.to raise_error(ArgumentError)
      end
    end

    context "a redirect" do
      it "trump an archive" do
        expect(redirect).to be > archive
        expect(archive).to be < redirect
      end

      it "trumps an unresolved" do
        expect(redirect).to be > unresolved
        expect(unresolved).to be < redirect
      end

      it "trumps a later redirect" do
        expect(redirect).to be > later_redirect
        expect(later_redirect).to be < redirect
      end
    end

    context "an archive" do
      it "trumps an unresolved" do
        expect(archive).to be > unresolved
        expect(unresolved).to be < archive
      end

      it "trumps a later archive" do
        expect(archive).to be > later_archive
        expect(later_archive).to be < archive
      end
    end

    context "an archive with a custom URL" do
      it "trumps a regular archive" do
        expect(custom_archive).to be > archive
        expect(archive).to be < custom_archive
      end

      it "trumps a later custom archive" do
        expect(custom_archive).to be > later_custom_archive
        expect(later_custom_archive).to be < custom_archive
      end
    end
  end
end
