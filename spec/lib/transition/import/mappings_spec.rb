require 'spec_helper'
require 'transition/import/mappings'

describe Transition::Import::Mappings do
  describe '.from_redirector_csv_file!', testing_before_all: true do
    before :all do
      create :site, abbr: 'ago' do |site|
        site.hosts << create(:host, hostname: 'www.ago.gov.uk')
      end

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
end
