require 'spec_helper'

describe MappingsBatchOutcomePresenter do
  let!(:site) { create(:site) }

  describe '#success_message' do
    let(:batch) { create(:mappings_batch, site: site, tag_list: 'fee, fi, fo',
                          http_status: '410', update_existing: true,
                          paths: ['/a', '/B', '/c?canonical=no', '/might-exist']) }

    subject { MappingsBatchOutcomePresenter.new(batch).success_message }

    context 'when updating at least one existing mapping' do
      let!(:existing_mapping) { create(:mapping, site: site, path: '/might-exist', http_status: '410') }

      before { batch.process }

      it { should eql('3 mappings created and 1 mapping updated. All tagged with "fee, fi, fo".') }
    end

    context 'when updating only existing mappings' do
      let!(:existing_mappings) do
        create(:mapping, site: site, path: '/might-exist', http_status: '410')
        create(:mapping, site: site, path: '/a', http_status: '410')
        create(:mapping, site: site, path: '/b', http_status: '410')
        create(:mapping, site: site, path: '/c', http_status: '410')
      end

      before { batch.process }

      context 'when updating and tagging' do
        it { should eql('4 mappings updated and tagged with "fee, fi, fo"') }
      end

      context 'when not tagging' do
        before { batch.update_column(:tag_list, nil) }
        it { should eql('4 mappings updated') }
      end
    end

    context 'there are no pre-existing mappings' do
      before  { batch.process }

      context 'when creating some mappings and updating none' do
        it { should eql('4 mappings created and tagged with "fee, fi, fo"') }
      end

      context 'when creating some mappings, updating none and tagging none' do
        before { batch.update_column(:tag_list, nil) }

        it { should eql('4 mappings created') }
      end
    end
  end

  describe '#operation_description' do
    subject { MappingsBatchOutcomePresenter.new(batch).operation_description }

    context 'bulk adding archives' do
      let(:batch) { build(:mappings_batch, http_status: '410') }
      it { should eql('bulk-add-archive-ignore-existing') }
    end

    context 'bulk adding redirects' do
      let(:batch) { build(:mappings_batch, http_status: '301') }
      it { should eql('bulk-add-redirect-ignore-existing') }
    end

    context 'bulk adding archives with overwrite' do
      let(:batch) { build(:mappings_batch, http_status: '410', update_existing: true) }
      it { should eql('bulk-add-archive-overwrite-existing') }
    end

    context 'bulk adding redirects with overwrite' do
      let(:batch) { build(:mappings_batch, http_status: '301', update_existing: true) }
      it { should eql('bulk-add-redirect-overwrite-existing') }
    end
  end
end
