require 'spec_helper'
require 'transition/import/organisations'

describe Transition::Import::Organisations do
  describe '.from_whitehall!', testing_before_all: true do
    before :all do
      Transition::Import::Organisations.from_whitehall!
    end

    it 'has imported orgs' do
      Organisation.count.should == 425
    end

    describe 'an organisation with multiple parents' do
      let(:bis) { Organisation.find_by_whitehall_slug('department-for-business-innovation-skills') }
      let(:fco) { Organisation.find_by_whitehall_slug('foreign-commonwealth-office') }

      subject(:ukti) { Organisation.find_by_whitehall_slug('uk-trade-investment') }

      it { should_not be_nil }
      its(:abbreviation) { should eql 'UKTI' }
      its(:whitehall_slug) { should eql 'uk-trade-investment' }
      its(:whitehall_type) { should eql 'Non-ministerial department' }

      its(:parent_organisations) { should =~ [bis, fco] }
    end
  end
end
