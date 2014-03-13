require 'spec_helper'
require 'transition/import/create_mappings_from_host_paths'

describe Transition::Import::CreateMappingsFromHostPaths do
  before do
    @site = create(:site)
    @host = @site.hosts.first # default site factory creates a host
  end

  context 'a site with no HostPaths' do
    it 'should do nothing' do
      Transition::Import::CreateMappingsFromHostPaths.call(@site)
      Mapping.count.should eql(0)
    end
  end

  context 'a HostPath without a matching mapping' do
    before do
      path = "/foo?insignificant=1"
      c14n_path = @site.canonical_path(path)
      @host_path = create(:host_path,
          path: path,
          host: @host,
          path_hash: Digest::SHA1.hexdigest(path),
          c14n_path_hash: Digest::SHA1.hexdigest(c14n_path))
      Transition::Import::CreateMappingsFromHostPaths.call(@site)
    end

    it 'should create a mapping' do
      Mapping.count.should eql(1)
    end

    describe 'the mapping' do
      subject { @site.mappings.first }

      its(:path)        { should eql('/foo') }
      its(:path_hash)   { should eql(@host_path.c14n_path_hash) }
      its(:http_status) { should eql('410') }
    end

    # We're not refreshing the mappings-hits link in this task;
    # hits_mappings_relations should be run to do this.
    it 'should not modify the host_path' do
      @host_path.mapping_id.should be_nil
    end
  end
end
