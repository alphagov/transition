require "rails_helper"
require "transition/import/hits_mappings_relations"

describe Transition::Import::HitsMappingsRelations do
  describe ".refresh!" do
    before do
      @host = create :host, site: create(:site_without_host, query_params: "significant")
      @site = @host.site

      @other_host = create :host, site: create(:site_without_host)
      @other_site = @other_host.site

      @hit_with_mapping      = create :hit, path: "/this/exists?significant=1", host: @host
      @other_site_hit        = create :hit, path: "/this/exists?significant=1", host: @other_host
      @c14n_hit_with_mapping = create :hit, path: "/this/Exists?and=can&canonicalize=1&significant=1", host: @host
      @hit_without_mapping   = create :hit, path: "/this/does/not/exist", host: @host

      @mapping               = create :mapping, path: "/this/exists?significant=1", site: @site
      @other_site_mapping    = create :mapping, path: "/this/exists?significant=1", site: @other_site

      Transition::Import::HitsMappingsRelations.refresh!
    end

    it "points the hit for which there is a path at the corresponding mapping" do
      expect(@hit_with_mapping.reload.mapping).to eq(@mapping)
    end

    it "points the c14nable hit for which there is a path at the corresponding mapping" do
      expect(@c14n_hit_with_mapping.reload.mapping).to eq(@mapping)
    end

    it "leaves the hit for which there is no mapping alone" do
      expect(@hit_without_mapping.reload.mapping).to be_nil
    end

    it "has a HostPath per uncanonicalized hit (all of them!)" do
      expect(HostPath.all.size).to eq(4)
    end

    it "precomputes the total hits for mappings across all sites" do
      expect(@mapping.reload.hit_count).to eq(@hit_with_mapping.count + @c14n_hit_with_mapping.count)
      expect(@other_site_mapping.reload.hit_count).to eq(@other_site_hit.count)
    end

    it "points the offsite hit at it's own site" do
      expect(@other_site_hit.reload.mapping).to eq(@other_site_mapping)
    end

    describe "The first HostPath" do
      subject { HostPath.where(path: "/this/Exists?and=can&canonicalize=1&significant=1").first }

      describe "#canonical_path" do
        subject { super().canonical_path }
        it { is_expected.to eql("/this/exists?significant=1") }
      end
    end

    context "when canonicalization has changed since a previous refresh" do
      before do
        @site.query_params = "canonicalize:significant"
        @site.save!

        @new_mapping = create :mapping, path: @c14n_hit_with_mapping.path, site: @site
        Transition::Import::HitsMappingsRelations.refresh!
        [@hit_with_mapping, @c14n_hit_with_mapping].each(&:reload)
      end

      it "should have linked the new mapping to the existing c14n hit" do
        expect(@c14n_hit_with_mapping.mapping).to eql(@new_mapping)
      end

      it "should have linked the new mapping to the existing host_path" do
        host_path = HostPath.where(path: @c14n_hit_with_mapping.path).first
        expect(host_path.mapping).to eql(@new_mapping)
      end
    end
  end

  describe ".refresh! for a specific site", testing_before_all: true do
    before :all do
      @host = create :host, site: create(:site_without_host)
      @site = @host.site

      @other_host = create :host
      @other_site = @other_host.site

      @hit            = create :hit, path: "/a", host: @host, hit_on: 1.week.ago, count: 10
      @hit2           = create :hit, path: "/a", host: @host, hit_on: 2.weeks.ago, count: 20

      @other_site_hit = create :hit, path: "/b", host: @other_host

      @mapping = create :mapping, path: "/a", site: @site

      @other_mapping_with_host_path = create :mapping, path: "/b2", site: @other_site
      create :host_path, path: "/b2", host: @other_host

      @mapping_connected_previously = create :mapping, path: "/b3", site: @other_site
      create :host_path, path: "/b3", host: @other_host, mapping: @mapping_connected_previously
      @hit_connected_previously = create :hit, mapping: @mapping_connected_previously

      Transition::Import::HitsMappingsRelations.refresh!(@site)
    end

    it "creates host_paths for this site" do
      expect(@site.host_paths.find_by(path: @hit.path)).to be_a(HostPath)
    end

    it "connects mappings to hits for this site" do
      expect(@hit.reload.mapping).not_to be_nil
    end

    it "does not create host_paths for another site" do
      expect(@other_site.host_paths.find_by(path: @other_site_hit.path)).to be_nil
    end

    it "does not connect mappings and pre-existing host_paths for another site" do
      path = @other_mapping_with_host_path.path
      expect(@other_site.host_paths.find_by(path: path).mapping).to be_nil
    end

    it "does not connect mappings and hits for another site" do
      expect(@other_site_hit.reload.mapping).to be_nil
    end

    it "precomputes hit counts for mappings for this site" do
      expect(@mapping.reload.hit_count).to eq(@hit.count + @hit2.count)
    end

    it "does not precompute Mapping#hit_count for another site" do
      expect(@mapping_connected_previously.reload.hit_count).to eql(0)
    end
  end
end
