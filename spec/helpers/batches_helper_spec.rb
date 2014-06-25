require 'spec_helper'

describe BatchesHelper do
  describe '#errors_for_raw_csv?' do
    before { batch.valid? }  # We need to validate before checking for errors

    subject { helper.errors_for_raw_csv?(batch) }

    context 'the batch has no errors' do
      let(:batch) { build :import_batch, raw_csv: '/a,' }
      it { should be_false }
    end

    context 'the batch has errors for raw_csv' do
      let(:batch) { build :import_batch, raw_csv: '' }
      it { should be_true }
    end

    context 'the batch has errors for canonical_paths' do
      let(:batch) { build :import_batch, raw_csv: 'a' }
      it { should be_true }
    end

    context 'the batch has errors for old_urls' do
      let(:batch) { build :import_batch, raw_csv: 'http://a.com/a' }
      it { should be_true }
    end

    context 'the batch has errors for new_urls' do
      let(:batch) { build :import_batch, raw_csv: '/a,http://unwhitelisted.com' }
      it { should be_true }
    end
  end
end
