require 'spec_helper'
require 'transition/import/organisations'
require 'transition/import/sites'

describe Transition::Import::Organisations do
  describe '.from_whitehall!', testing_before_all: true do
    before :all do
      Transition::Import::Organisations.from_whitehall!(
        Transition::Import::WhitehallOrgs.new('spec/fixtures/whitehall/orgs_abridged.yml')
      )
    end

    it 'has imported orgs - one per org in abridged plus two special cases' do
      Organisation.count.should == 8
    end

    describe 'the special cases' do
      it 'creates directgov' do
        Organisation.find_by_whitehall_slug('directgov').should_not be_nil
      end

      it 'creates businesslink' do
        Organisation.find_by_whitehall_slug('business-link').should_not be_nil
      end
    end

    describe 'an organisation with multiple parents' do
      let(:bis) { Organisation.find_by_whitehall_slug('department-for-business-innovation-skills') }
      let(:fco) { Organisation.find_by_whitehall_slug('foreign-commonwealth-office') }

      subject(:ukti) { Organisation.find_by_whitehall_slug('uk-trade-investment') }

      its(:abbreviation)   { should eql 'UKTI' }
      its(:whitehall_slug) { should eql 'uk-trade-investment' }
      its(:whitehall_type) { should eql 'Non-ministerial department' }
      its(:homepage)       { should eql 'https://www.gov.uk/government/organisations/uk-trade-investment' }

      its(:parent_organisations) { should =~ [bis, fco] }
    end
  end
end
