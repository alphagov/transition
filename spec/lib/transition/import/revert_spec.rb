require "rails_helper"
require "transition/import/revert"

describe Transition::Import::Revert::Sites do
  describe "#revert_all!" do
    before do
      @bona_vacantia = create :organisation, whitehall_slug: "bona-vacantia"
      Transition::Import::OrgsSitesHosts.from_yaml!(
        "spec/fixtures/sites/someyaml/**/*.yml",
        Transition::Import::WhitehallOrgs.new("spec/fixtures/whitehall/orgs_abridged.yml"),
      )

      @original_site_count = 8
      @original_host_count = 24
      @original_bv_extra_sites_count = 1
      expect(Site.count).to eql(@original_site_count)
      expect(Host.count).to eql(@original_host_count)
      expect(@bona_vacantia.extra_sites.count).to eql(@original_bv_extra_sites_count)
    end

    context "deleting sites which can be deleted" do
      site_abbrs = %w[ago bis]

      before do
        Transition::Import::Revert::Sites.new(site_abbrs).revert_all!
      end

      it "should have deleted the sites" do
        expect(Site.count).to eql(6)
        expect(Site.where(abbr: site_abbrs)).to be_empty
      end

      it "should have deleted the hosts" do
        expect(Host.count).to eql(14)
        expect(Host.find_by(hostname: "www.bis.gov.uk")).to be_nil
      end

      it "should have deleted the sites' links to extra organisations" do
        expect(@bona_vacantia.extra_sites.size).to eql(0)
      end
    end

    context "trying to delete a site which has a mapping" do
      before do
        ago = Site.find_by(abbr: "ago")
        create :mapping, site: ago
        Transition::Import::Revert::Sites.new([ago.abbr]).revert_all!
      end

      it "should not delete the site or any related data" do
        expect(Site.count).to eql(@original_site_count)
        expect(Host.count).to eql(@original_host_count)
        expect(@bona_vacantia.extra_sites.count).to eql(@original_bv_extra_sites_count)
      end
    end

    context "trying to delete a site which has hits" do
      before do
        ago = Site.find_by(abbr: "ago")
        create :hit, host: ago.hosts.first
        Transition::Import::Revert::Sites.new([ago.abbr]).revert_all!
      end

      it "should not delete the site or any related data" do
        expect(Site.count).to eql(@original_site_count)
        expect(Host.count).to eql(@original_host_count)
        expect(@bona_vacantia.extra_sites.count).to eql(@original_bv_extra_sites_count)
      end
    end

    context "trying to delete a site which doesn't exist" do
      before do
        Transition::Import::Revert::Sites.new(%w[nonexistent_site]).revert_all!
      end

      it "should not delete any sites or any related data" do
        expect(Site.count).to eql(@original_site_count)
        expect(Host.count).to eql(@original_host_count)
        expect(@bona_vacantia.extra_sites.count).to eql(@original_bv_extra_sites_count)
      end
    end
  end
end
