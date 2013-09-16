require 'spec_helper'
require 'transition/import/mappings'

describe Transition::Import::Mappings do
  def create_test_sites
    @ago_site = create :site, abbr: 'ago' do |site|
      site.hosts << create(:host, hostname: 'www.ago.gov.uk')
    end
    @directgov_site = create :site, abbr: 'dg' do |site|
      site.hosts << create(:host, hostname: 'www.direct.gov.uk')
    end
  end

  describe '.from_redirector_csv_file!' do
    context 'a single import from a file with no suggested/archive URLs', testing_before_all: true do
      before :all do
        create_test_sites
        Transition::Import::Mappings.from_redirector_csv_file!('spec/fixtures/mappings/ago_abridged.csv')
      end

      it 'has imported mappings' do
        Mapping.count.should == 3
      end

      describe 'the first mapping' do
        subject(:mapping) { Mapping.first }

        its(:new_url)   { should eql('https://www.gov.uk/government/organisations/attorney-generals-office') }
        its(:path)      { should eql('/_layouts/feed.aspx') }
        its(:path_hash) { should eql('160d40c3b5400e446d0c5f2f62fd7a419b62f7f6') }
      end
    end

    context 'an import with updates to a file with suggested/archive URLs', testing_before_all: true do
      before :all do
        create_test_sites
        Transition::Import::Mappings.from_redirector_csv_file!('spec/fixtures/mappings/directgov_abridged.csv')
        Transition::Import::Mappings.from_redirector_csv_file!('spec/fixtures/mappings/updated/directgov_updated.csv')
      end

      it 'has registered the new mapping' do
        Mapping.find_by_path('/new-mapping').should_not be_nil
      end

      describe 'the update of the old mapping' do
        subject(:updated_mapping) { @directgov_site.mappings.where(path: '/barrierbusting').first }

        its(:new_url)       { should eql('http://new.url') }
        its(:suggested_url) { should include('barrierbusting.updated') }
        its(:archive_url)   { should include('webarchive.updated') }
      end
    end
  end

  describe '.from_redirector_mask!', testing_before_all: true do
    before :all do
      create_test_sites
      Transition::Import::Mappings.from_redirector_mask!('spec/fixtures/mappings/*.csv')
    end

    it 'imported mappings from both files' do
      Mapping.count.should == 6
    end

    describe 'the directgov mapping with suggested and archive urls' do
      subject { Mapping.find_by_path!('/barrierbusting') }
      its(:suggested_url) { should eql('http://barrierbusting.communities.gov.uk/') }
      its(:archive_url)   { should eql('http://webarchive.nationalarchives.gov.uk/20121015000000/www.direct.gov.uk/en/Nl1/Newsroom/DG_192969')}
    end
  end

end
