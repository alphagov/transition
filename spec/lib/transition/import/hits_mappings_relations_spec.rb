require 'spec_helper'
require 'transition/import/hits_mappings_relations'

describe Transition::Import::HitsMappingsRelations do
  describe '.refresh!', testing_before_all: true do
    before :all do
      @host = create :host, site: create(:site, query_params: 'significant')
      @site = @host.site

      @other_host = create :host

      @hit_with_mapping      = create :hit, path: '/this/exists?significant=1', host: @host
      @other_site_hit        = create :hit, path: '/this/exists?significant=1', host: @other_host
      @c14n_hit_with_mapping = create :hit, path: '/this/Exists?and=can&canonicalize=1&significant=1', host: @host
      @hit_without_mapping   = create :hit, path: '/this/does/not/exist', host: @host

      @mapping               = create :mapping, path: '/this/exists?significant=1', site: @site

      Transition::Import::HitsMappingsRelations.refresh!
    end

    it 'points the hit for which there is a path at the corresponding mapping' do
      @hit_with_mapping.reload.mapping.should == @mapping
    end

    it 'points the c14nable hit for which there is a path at the corresponding mapping' do
      @c14n_hit_with_mapping.reload.mapping.should == @mapping
    end

    it 'leaves the hit for which there is no mapping alone' do
      @hit_without_mapping.reload.mapping.should be_nil
    end

    it 'has a HostPath per uncanonicalized hit (all of them!)' do
      HostPath.all.should have(4).host_paths
    end

    it 'does not point the offsite hit at the mapping incorrectly' do
      @other_site_hit.reload.mapping.should be_nil
    end

    describe 'The first HostPath' do
      subject { HostPath.where(path: '/this/Exists?and=can&canonicalize=1&significant=1').first }

      its(:path_hash)      { should eql(Digest::SHA1.hexdigest('/this/Exists?and=can&canonicalize=1&significant=1')) }
      its(:c14n_path_hash) { should eql(Digest::SHA1.hexdigest('/this/exists?significant=1')) }
    end
  end
end
