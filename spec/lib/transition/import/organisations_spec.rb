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

    it 'has imported orgs' do
      Organisation.count.should == 6
    end

    describe 'an organisation with multiple parents' do
      let(:bis) { Organisation.find_by_whitehall_slug('department-for-business-innovation-skills') }
      let(:fco) { Organisation.find_by_whitehall_slug('foreign-commonwealth-office') }

      subject(:ukti) { Organisation.find_by_whitehall_slug('uk-trade-investment') }

      its(:abbreviation)   { should eql 'UKTI' }
      its(:whitehall_slug) { should eql 'uk-trade-investment' }
      its(:whitehall_type) { should eql 'Non-ministerial department' }

      its(:parent_organisations) { should =~ [bis, fco] }
    end

    describe 'an organisation with a site in redirector' do
      subject(:bis) { Organisation.find_by_whitehall_slug(
        'department-for-business-innovation-skills') }
      it 'sets the redirector_abbr the same as whitehall_slug' do
        bis.redirector_abbr.should eql 'department-for-business-innovation-skills'
      end
    end

  end
end
