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

    describe 'old URLs' do
      let(:site) { create(:site_without_host, hosts: [create(:host, hostname: 'a.com')]) }

      describe 'old_urls includes URLs for this site' do
        subject(:mappings_batch) do
          build(:import_batch, site: site, raw_csv: <<-CSV.strip_heredoc
              old url,new url
              http://a.com/old,
            CSV
          )
        end

        it { should be_valid }
      end

      describe 'old_urls includes URLs which are not for this site' do
        subject(:mappings_batch) do
          build(:import_batch, site: site, raw_csv: <<-CSV.strip_heredoc
              old url,new url
              http://other.com/old,
            CSV
          )
        end

        it { should_not be_valid }
        it 'should declare them invalid' do
          mappings_batch.valid?
          mappings_batch.errors[:old_urls].should == ['One or more of the URLs entered are not part of this site']
        end
      end

      describe 'old URLs would be empty after canonicalisation' do
        subject(:mappings_batch) do
          build(:import_batch, site: site, raw_csv: <<-CSV.strip_heredoc
              old url,new url
              old,
            CSV
          )
        end

        before { mappings_batch.should_not be_valid }
        it 'should declare it invalid' do
          mappings_batch.errors[:canonical_paths].should == ['Enter at least one valid path']
        end
      end
    end

    describe 'new URLs' do
      describe 'validating all new URLs for length' do
        let(:too_long_url) { 'http://a.gov.uk'.ljust(65536, 'x') }
        subject(:mappings_batch) do
          build(:import_batch, raw_csv: <<-CSV.strip_heredoc
              old url,new url
              /old,#{too_long_url}
            CSV
          )
        end

        before { mappings_batch.should_not be_valid }
        it 'should declare it invalid' do
          mappings_batch.errors[:new_urls].should include("A new URL is too long")
        end
      end

      describe 'validating that all new URLs are valid URLs' do
        subject(:mappings_batch) do
          build(:import_batch, raw_csv: <<-CSV.strip_heredoc
              old url,new url
              /old,www.gov.uk
            CSV
          )
        end

        before { mappings_batch.should_not be_valid }
        it 'should declare it invalid' do
          mappings_batch.errors[:new_urls].should include('A new URL is invalid')
        end
      end

      describe 'validating that all new URLs are on the whitelist' do
        subject(:mappings_batch) do
          build(:import_batch, raw_csv: <<-CSV.strip_heredoc
              old url,new url
              /old,http://evil.com
            CSV
          )
        end

        before { mappings_batch.should_not be_valid }
        it 'should declare it invalid' do
          mappings_batch.errors[:new_urls].should include('The URL to redirect to must be on a whitelisted domain. Contact transition-dev@digital.cabinet-office.gov.uk for more information.')
        end
      end

      context 'when an invalid new URL appears multiple times in the raw CSV' do
        subject(:mappings_batch) do
          build(:import_batch, raw_csv: <<-CSV.strip_heredoc
              /old-1,http://evil.com
              /old-2,http://evil.com
              /old-3,http://evil.com
              /old-4,http://evil.com
              /old-5,http://evil.com
              /old-6,http://also-bad.com
            CSV
          )
        end

        before { mappings_batch.should_not be_valid }
        it 'should include the error message once per unique new URL' do
          expect(mappings_batch.errors[:new_urls].size).to eql(2)
        end
      end
    end
  end

  describe 'creating entries' do
    let(:site) { create(:site, query_params: 'significant') }
    let!(:mappings_batch) { create(:import_batch, site: site,
                                        raw_csv: raw_csv
                                      ) }
    context 'rosy case' do
      let(:raw_csv) { <<-CSV.strip_heredoc
                        /old,https://www.gov.uk/new
                      CSV
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
      let(:raw_csv) { <<-CSV.strip_heredoc
                        old url,new url
                        /old,https://www.gov.uk/new
                        old_url, new_url
                      CSV
                    }

      it 'should ignore headers' do
        mappings_batch.entries.count.should == 1
        entry = mappings_batch.entries.first
        entry.path.should == '/old'
      end
    end

    context 'with blank lines' do
      let(:raw_csv) { <<-CSV.strip_heredoc
                        /old,https://www.gov.uk/new

                      CSV
                    }

      it 'should ignore blank lines' do
        mappings_batch.entries.count.should == 1
        entry = mappings_batch.entries.first
        entry.path.should == '/old'
      end
    end

    context 'archives' do
      let(:raw_csv) { <<-CSV.strip_heredoc
                  /old,TNA
                CSV
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
      let(:raw_csv) { <<-CSV.strip_heredoc
                  /old
                CSV
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

    context 'the old URL is an absolute URL, not a path' do
      let(:raw_csv) { <<-CSV.strip_heredoc
                  http://#{site.default_host.hostname}/old
                CSV
              }

      it 'sets the path to be only the path' do
        mappings_batch.entries.first.path.should eql('/old')
      end
    end

    context 'the old URL canonicalizes to a homepage path' do
      let(:raw_csv) { <<-CSV.strip_heredoc
                  /?foo
                  /a
                CSV
              }

      it 'does not create an entry for the homepage row' do
        mappings_batch.entries.pluck(:path).should eql(['/a'])
      end
    end

    context 'deduplicating rows' do
      let(:raw_csv) { <<-CSV.strip_heredoc
                  /old,
                  /old?insignificant,TNA
                  /OLD,http://a.gov.uk/new
                  /old,http://a.gov.uk/ignore-later-redirects
                CSV
              }

      it 'should canonicalize and deduplicate before creating entries' do
        mappings_batch.entries.count.should == 1

        entry = mappings_batch.entries.first
        entry.path.should == '/old'
        entry.new_url.should == 'http://a.gov.uk/new'
        entry.type.should == 'redirect'
      end
    end

    context 'existing mappings' do
      let(:existing_mapping) { create(:mapping, site: site, path: '/old') }
      let(:raw_csv) { <<-CSV.strip_heredoc
                        #{existing_mapping.path}
                      CSV
                    }

      it 'should relate the entry to the existing mapping' do
        entry = mappings_batch.entries.detect { |entry| entry.path == existing_mapping.path }
        entry.should_not be_nil
        entry.mapping.should == existing_mapping
      end
    end
  end

  describe '#process' do
    let(:site) { create(:site) }

    subject(:mappings_batch) do
      create(:import_batch, site: site,
             tag_list: ['a tag'],
             raw_csv: <<-CSV.strip_heredoc
                        /a,http://a.gov.uk
                        /b,http://a.gov.uk
                      CSV
                 )
    end

    include_examples 'creates mappings'
  end
end
