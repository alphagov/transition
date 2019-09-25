require "rails_helper"
require "transition/import/mappings_from_host_paths"

describe Transition::Import::MappingsFromHostPaths do
  before do
    @site = create(:site)
    @host = @site.hosts.first # default site factory creates a host
  end

  after do
    # HostPath is MyISAM. MyISAM doesn't support transactions so
    # DatabaseCleaner's strategy of using transactions and rolling back doesn't
    # work.
    HostPath.delete_all
  end

  context "a site with no HostPaths" do
    it "should do nothing" do
      Transition::Import::MappingsFromHostPaths.refresh!(@site)
      expect(Mapping.count).to eql(0)
    end
  end

  context "a HostPath without a matching mapping" do
    before do
      path = "/foo?insignificant=1"
      @host_path = create(:host_path, path: path, host: @host)
      Transition::Import::MappingsFromHostPaths.refresh!(@site)
    end

    it "should create a mapping" do
      expect(Mapping.count).to eql(1)
    end

    describe "the mapping" do
      subject { @site.mappings.first }

      describe "#path" do
        subject { super().path }
        it { is_expected.to eql("/foo") }
      end

      describe "#type" do
        subject { super().type }
        it { is_expected.to eql("unresolved") }
      end
    end

    # We're not refreshing the mappings-hits link in this task;
    # hits_mappings_relations should be run to do this.
    it "should not modify the host_path" do
      expect(@host_path.mapping_id).to be_nil
    end

    describe "should create a history entry", versioning: true do
      let(:mapping) { @site.mappings.first }
      subject { mapping.versions.first }

      describe "#item_id" do
        subject { super().item_id }
        it { is_expected.to eql(mapping.id) }
      end

      describe "#whodunnit" do
        subject { super().whodunnit }
        it { is_expected.to eql("Logs mappings robot") }
      end
    end

    context "another site has HostPaths" do
      before do
        @another_site = create(:site)
        create(:host_path, path: "/bar", host: @another_site.hosts.first)
        Transition::Import::MappingsFromHostPaths.refresh!(@site)
      end

      it "should not create mappings for the other site" do
        expect(@another_site.mappings.count).to eql(0)
        expect(@site.mappings.count).to eql(1)
      end
    end
  end

  context "a HostPath with a matching mapping" do
    before do
      path = "/foo?insignificant=1"
      create(:host_path, path: path, host: @host)
      @mapping = create(:redirect, path: path, site: @site)
      Transition::Import::MappingsFromHostPaths.refresh!(@site)
    end

    it "should not create any more mappings" do
      expect(Mapping.count).to eql(1)
    end

    describe "the (unchanged) existing mapping" do
      subject { @mapping }

      describe "#type" do
        subject { super().type }
        it { is_expected.to eql("redirect") }
      end
    end
  end

  context "a site with multiple hosts" do
    before do
      @site.hosts << @second_host = build(:host)
      @site.hosts.each do |host|
        path = "/foo-on-#{host.hostname}"
        create(:host_path, path: path, host: host)
      end
      Transition::Import::MappingsFromHostPaths.refresh!(@site)
    end

    it "should create mappings for HostPaths for each host" do
      expect(@site.mappings.count).to eql(2)
    end
  end

  context "a site with multiple hosts and the same path on each host" do
    before do
      @site.hosts << @second_host = build(:host)
      path = "/foo"
      @site.hosts.each do |host|
        create(:host_path, path: path, host: host)
      end
      Transition::Import::MappingsFromHostPaths.refresh!(@site)
    end

    it "should create one mapping" do
      expect(@site.mappings.count).to eql(1)
    end
  end
end
