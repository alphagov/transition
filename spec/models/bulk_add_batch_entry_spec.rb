require 'spec_helper'

describe BulkAddBatchEntry do
  describe 'disabled fields' do
    describe 'should define getters for those fields and delegate them to the batch' do
      let(:mappings_batch) { build(:bulk_add_batch, new_url: 'http://cheese', type: 'redirect') }

      subject(:entry) { build(:bulk_add_batch_entry, mappings_batch: mappings_batch) }

      its(:new_url)   { should eql('http://cheese') }
      its(:type)      { should eql('redirect') }
      its(:redirect?) { should be_true }
    end
  end
end
