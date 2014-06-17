require 'spec_helper'

describe ImportBatch do
  describe 'disabled fields' do
    it 'should prevent access to fields which are irrelevant to this subclass' do
      expect{ ImportBatch.new.type }.to raise_error(NoMethodError)
      expect{ ImportBatch.new.new_url }.to raise_error(NoMethodError)
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:raw_csv).with_message('Enter at least one valid line') }
  end

  describe 'creating entries' do
    let(:site) { create(:site, query_params: 'significant') }
    let!(:mappings_batch) { create(:import_batch, site: site,
                                        raw_csv: raw_csv
                                      ) }
    context 'rosy case' do
      let(:raw_csv) { <<-HEREDOC.strip_heredoc
                        /old,https://www.gov.uk/new
                      HEREDOC
                    }

      it 'should create an entry for each data row' do
        mappings_batch.entries.count.should == 1
      end

      describe 'the first entry' do
        subject(:entry) { mappings_batch.entries.first }

        its(:path)    { should == '/old' }
        its(:new_url) { should == 'https://www.gov.uk/new' }
        its(:type)    { should == 'redirect' }
        it 'should create an entry of the right subclass' do
          entry.should be_a(ImportBatchEntry)
        end
      end
    end

    context 'with headers' do
      let(:raw_csv) { <<-HEREDOC.strip_heredoc
                        old url,new url
                        /old,https://www.gov.uk/new
                      HEREDOC
                    }

      it 'should ignore headers in the first row' do
        mappings_batch.entries.count.should == 1
        entry = mappings_batch.entries.first
        entry.path.should == '/old'
      end
    end

    context 'archives' do
      let(:raw_csv) { <<-HEREDOC.strip_heredoc
                  /old,TNA
                HEREDOC
              }
      it 'should create an entry for each data row' do
        mappings_batch.entries.count.should == 1
      end

      describe 'the first entry' do
        subject(:entry) { mappings_batch.entries.first }

        its(:path)    { should == '/old' }
        its(:new_url) { should be_nil }
        its(:type)    { should == 'archive' }
      end
    end

    context 'unresolved' do
      let(:raw_csv) { <<-HEREDOC.strip_heredoc
                  /old
                HEREDOC
              }
      it 'should create an entry for each data row' do
        mappings_batch.entries.count.should == 1
      end

      describe 'the first entry' do
        subject(:entry) { mappings_batch.entries.first }

        its(:path)    { should == '/old' }
        its(:new_url) { should be_nil }
        its(:type)    { should == 'unresolved' }
      end
    end
  end
end
