require 'spec_helper'
require 'transition/import/mappings_from_host_paths'

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

  context 'a site with no HostPaths' do
    it 'should do nothing' do
      Transition::Import::MappingsFromHostPaths.refresh!(@site)
      Mapping.count.should eql(0)
    end
  end

  context 'a HostPath without a matching mapping' do
    before do
      path = "/foo?insignificant=1"
      @host_path = create(:host_path, path: path, host: @host)
      Transition::Import::MappingsFromHostPaths.refresh!(@site)
    end

    it 'should create a mapping' do
      Mapping.count.should eql(1)
    end

    describe 'the mapping' do
      subject { @site.mappings.first }

      its(:path)        { should eql('/foo') }
      its(:path_hash)   { should eql(@host_path.c14n_path_hash) }
      its(:type)        { should eql('archive') }
    end

    # We're not refreshing the mappings-hits link in this task;
    # hits_mappings_relations should be run to do this.
    it 'should not modify the host_path' do
      @host_path.mapping_id.should be_nil
    end

    describe 'should create a history entry', versioning: true do
      let(:mapping) { @site.mappings.first }
      subject { mapping.versions.first }

      its(:item_id)   { should eql(mapping.id) }
      its(:whodunnit) { should eql('Logs mappings robot') }
    end

    context 'another site has HostPaths' do
      before do
        @another_site = create(:site)
        create(:host_path, path: '/bar', host: @another_site.hosts.first)
        Transition::Import::MappingsFromHostPaths.refresh!(@site)
      end

      it 'should not create mappings for the other site' do
        @another_site.mappings.count.should eql(0)
        @site.mappings.count.should eql(1)
      end
    end
  end

  context 'a HostPath with a matching mapping' do
    before do
      path = '/foo?insignificant=1'
      create(:host_path, path: path, host: @host)
      @mapping = create(:redirect, path: path, site: @site)
      Transition::Import::MappingsFromHostPaths.refresh!(@site)
    end

    it 'should not create any more mappings' do
      Mapping.count.should eql(1)
    end

    describe 'the (unchanged) existing mapping' do
      subject { @mapping }

      its(:type) { should eql('redirect') }
    end
  end

  context 'a site with multiple hosts' do
    before do
      @site.hosts << @second_host = build(:host)
      @site.hosts.each do |host|
        path = "/foo-on-#{host.hostname}"
        create(:host_path, path: path, host: host)
      end
      Transition::Import::MappingsFromHostPaths.refresh!(@site)
    end

    it 'should create mappings for HostPaths for each host' do
      @site.mappings.count.should eql(2)
    end
  end

  context 'a site with multiple hosts and the same path on each host' do
    before do
      @site.hosts << @second_host = build(:host)
      path = '/foo'
      @site.hosts.each do |host|
        create(:host_path, path: path, host: host)
      end
      Transition::Import::MappingsFromHostPaths.refresh!(@site)
    end

    it 'should create one mapping' do
      @site.mappings.count.should eql(1)
    end
  end
end
