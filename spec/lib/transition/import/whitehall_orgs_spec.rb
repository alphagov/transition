require 'spec_helper'
require 'transition/import/whitehall_orgs'

describe Transition::Import::WhitehallOrgs do
  context 'with an API response stubbed to fixtures' do
    subject(:whitehall_orgs) do
      Transition::Import::WhitehallOrgs.new('spec/fixtures/whitehall/orgs_abridged.yml')
    end

    it { should have(6).organisations }

    describe '#by_id' do
      subject(:ago) do
        whitehall_orgs.by_id[
          'https://whitehall-admin.production.alphagov.co.uk/api/organisations/attorney-generals-office'
        ]
      end

      it                   { should be_an(OpenStruct) }
      specify              { ago.format.should == 'Ministerial department' }
      its(:'details.slug') { should == 'attorney-generals-office' }
    end
  end
end
