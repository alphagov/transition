require 'spec_helper'

describe Mapping do
  describe 'relationships' do
    it { should belong_to(:site) }
  end

  describe 'the path hash' do
    let(:some_path) { '/a/b/c' }

    subject(:mapping) do
      build :mapping, path: some_path, site: build(:site), http_status: 301
    end

    before { mapping.save.should be_true }

    its(:path_hash) do
      should eql(Digest::SHA1.hexdigest(some_path))
    end
  end
end