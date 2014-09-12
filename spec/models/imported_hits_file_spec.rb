require 'spec_helper'

describe ImportedHitsFile do
  describe 'validations' do
    it { should validate_presence_of(:filename) }
    it { should validate_uniqueness_of(:filename) }
  end

  let(:test_file) do
    'spec/fixtures/hits/tmp_changed_hits_file.tsv'.tap do |altered_file|
      FileUtils.cp('spec/fixtures/hits/businesslink_2012-10-14.tsv', altered_file)
    end
  end

  let!(:imported_file) { ImportedHitsFile.create(filename: test_file) }

  it 'has populated the hash on creation' do
    imported_file.content_hash.should == '0c7983bae4804f6eea465f5bcb0faf53a863ae8c'
  end

  describe '#same_on_disk?' do
    subject { imported_file.same_on_disk? }

    context 'when a file on disk is no different from the stored hash' do
      it { should be_true }
    end

    context 'when a file on disk is different from the stored hash' do
      before { File.open(test_file, 'a') { |f| f.puts 'a change' } }
      it     { should be_false }
    end
  end

  after { File.delete(test_file) }
end
