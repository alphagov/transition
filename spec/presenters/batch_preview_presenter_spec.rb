require "rails_helper"

describe BatchPreviewPresenter, testing_before_all: true do
  before :all do
    site = create(:site)
    create(:mapping, site: site, path: "/3")
    batch = create(:import_batch, site: site, raw_csv: <<-CSV.strip_heredoc
                        /1,TNA
                        /2,TNA
                        /3,https://www.gov.uk/has-existing-mapping
                        /4
                        /5
                        /6
                        /7
                        /8
                        /9
                        /10
                        /11
                        /12
                        /13
                        /14
                        /15
                        /16
                        /17
                        /18
                        /19
                        /20
                        /21
    CSV
    )
    @preview = BatchPreviewPresenter.new(batch)
  end

  describe "counts of entries without existing mappings" do
    describe "#redirect_count" do
      it "should only include redirect entries" do
        expect(@preview.redirect_count).to eql(0)
      end
    end

    describe "#archive_count" do
      it "should only include archive entries" do
        expect(@preview.archive_count).to eql(2)
      end
    end

    describe "#unresolved_count" do
      it "should only include unresolved entries" do
        expect(@preview.unresolved_count).to eql(18)
      end
    end
  end

  describe "#existing_mappings_count" do
    it "should count the entries (of all types) which have existing mappings" do
      expect(@preview.existing_mappings_count).to eql(1)
    end
  end

  describe "#mappings" do
    it "should include only the first 20 entries (including those with existing mappings)" do
      expect(@preview.mappings.size).to eql(20)
    end
  end
end
