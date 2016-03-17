require 'rails_helper'

describe ImportedHitsFile do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:filename) }
    it { is_expected.to validate_uniqueness_of(:filename) }
  end

  let(:test_file) do
    'spec/fixtures/hits/tmp_changed_hits_file.tsv'.tap do |altered_file|
      FileUtils.cp('spec/fixtures/hits/businesslink_2012-10-14.tsv', altered_file)
    end
  end

  let!(:imported_file) { ImportedHitsFile.create(filename: test_file) }

  it 'has populated the hash on creation' do
    expect(imported_file.content_hash).to eq('0c7983bae4804f6eea465f5bcb0faf53a863ae8c')
  end

  describe '#same_on_disk?' do
    subject { imported_file.same_on_disk? }

    context 'when a file on disk is no different from the stored hash' do
      it { is_expected.to be_truthy }
    end

    context 'when a file on disk is different from the stored hash' do
      before { File.open(test_file, 'a') { |f| f.puts 'a change' } }
      it     { is_expected.to be_falsey }
    end

    context 'when a file on disk no longer exists' do
      before { File.delete(test_file) }
      it     { is_expected.to be_falsey }
    end
  end

  after { File.delete(test_file) if File.exists?(test_file) }
end
