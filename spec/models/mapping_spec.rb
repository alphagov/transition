require 'spec_helper'

describe Mapping do
  describe 'relationships' do
    it { should belong_to(:site) }
  end

  describe 'validations' do
    it { should validate_presence_of(:site) }
    it { should validate_presence_of(:path) }
    it { should ensure_length_of(:path).is_at_most(1024) }
    it { should validate_presence_of(:http_status) }
    it { should ensure_length_of(:http_status).is_at_most(3) }
    it 'ensures paths are unique to a site' do
      create(:mapping_410)
      lambda { build(:mapping_410).save }.should raise_error(ActiveRecord::StatementInvalid)
    end

    it { should ensure_length_of(:new_url).is_at_most(64.kilobytes - 1)}
    it { should ensure_length_of(:suggested_url).is_at_most(64.kilobytes - 1)}
    it { should ensure_length_of(:archive_url).is_at_most(64.kilobytes - 1)}

    describe 'URL validations' do
      subject(:mapping) { build(:mapping, http_status: '301', new_url: 'not-a-url', suggested_url: 'http://', archive_url: '') }

      before { mapping.should_not be_valid }

      describe 'the errors' do
        subject { mapping.errors }

        its([:new_url])       { should == ['is not a URL'] }
        its([:suggested_url]) { should == ['is not a URL'] }
        its([:archive_url])   { should be_empty }
      end
    end
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
