require 'spec_helper'

describe HostPath do
  describe 'path canonicalization' do
    let(:uncanonicalized_path) { '/A/b/c?significant=1&really-significant=2&insignificant=2' }
    let(:canonicalized_path)   { '/a/b/c?really-significant=2&significant=1' }
    let(:site)                 { create(:site, query_params: 'significant:really-significant') }
    let(:host)                 { site.hosts.first }

    subject do
      create(:host_path, path: uncanonicalized_path, host: host)
    end

    its(:path)           { should eql(uncanonicalized_path) }
    its(:canonical_path) { should eql(canonicalized_path)   }
  end
end
