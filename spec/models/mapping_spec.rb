require 'spec_helper'

describe Mapping do
  describe 'relationships' do
    it { should belong_to(:site) }
  end

  describe 'the path hash' do
    let(:path) { '/a/b/c' }
    subject(:mapping) do
      build :mapping, c14d_path: path, site: build(:site), http_status: 301
    end

    before { mapping.save.should be_true }

    its(:c14d_hash) { should eql(Digest::SHA1.hexdigest(path)) }
  end
end