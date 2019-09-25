require "rails_helper"

describe MappingCSVPresenter do
  describe "redirects" do
    let(:mapping) { create(:redirect, new_url: "http://new.gov.uk/a", archive_url: "http://webarchive.nationalarchives.gov.uk/*/http://a.com/foo", suggested_url: "http://c.com") }

    subject(:presenter) { MappingCSVPresenter.new(mapping) }

    it "hides Archive URLs and Suggested URLs" do
      expect(presenter.new_url).to eql("http://new.gov.uk/a")
      expect(presenter.archive_url).to be_nil
      expect(presenter.suggested_url).to be_nil
    end
  end

  describe "archives" do
    let(:mapping) { create(:archived, archive_url: "http://webarchive.nationalarchives.gov.uk/*/http://a.com/foo", suggested_url: "http://c.com") }

    subject(:presenter) { MappingCSVPresenter.new(mapping) }

    it "includes custom Archive URLs and Suggested URLs" do
      expect(presenter.new_url).to be_nil
      expect(presenter.archive_url).to eql("http://webarchive.nationalarchives.gov.uk/*/http://a.com/foo")
      expect(presenter.suggested_url).to eql("http://c.com")
    end
  end

  describe "unresolved mappings" do
    let(:mapping) { create(:unresolved, archive_url: "http://webarchive.nationalarchives.gov.uk/*/http://a.com/foo", suggested_url: "http://c.com") }

    subject(:presenter) { MappingCSVPresenter.new(mapping) }

    it "includes custom Archive URLs and Suggested URLs" do
      expect(presenter.new_url).to be_nil
      expect(presenter.archive_url).to eql("http://webarchive.nationalarchives.gov.uk/*/http://a.com/foo")
      expect(presenter.suggested_url).to eql("http://c.com")
    end
  end
end
