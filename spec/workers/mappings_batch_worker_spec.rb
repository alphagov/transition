require 'spec_helper'

describe MappingsBatchWorker do
  describe 'perform' do
    describe 'recording history', versioning: true do
      let(:user) { create(:user, name: 'Bob') }
      let(:mappings_batch) { create(:mappings_batch, user: user) }

      before { MappingsBatchWorker.new.perform(mappings_batch.id) }

      subject { Mapping.first.versions.last }

      its(:whodunnit) { should eql('Bob') }
      its(:user_id)   { should eql(user.id) }
    end
  end
end
