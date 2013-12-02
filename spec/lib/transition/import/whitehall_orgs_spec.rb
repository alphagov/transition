require 'spec_helper'
require 'transition/import/whitehall_orgs'

describe Transition::Import::WhitehallOrgs do
  context 'with an API response stubbed to fixtures' do
    subject(:whitehall_orgs) do
      Transition::Import::WhitehallOrgs.new.tap do |orgs|
        orgs.stub(:cached_org_path).and_return('spec/fixtures/whitehall/orgs.yml')
      end
    end

    it { should have(425).organisations }

    shared_examples 'Attorney General\'s Office' do
      it                   { should be_an(OpenStruct) }
      specify              { ago.format.should == 'Ministerial department' }
      its(:'details.slug') { should == 'attorney-generals-office' }
    end

    describe '#by_title' do
      subject(:ago) { whitehall_orgs.by_title['Attorney General\'s Office'] }

      it_behaves_like 'Attorney General\'s Office'
    end

    describe '#by_id' do
      subject(:ago) do
        whitehall_orgs.by_id[
          'https://whitehall-admin.production.alphagov.co.uk/api/organisations/attorney-generals-office'
        ]
      end
      it_behaves_like 'Attorney General\'s Office'
    end
  end
end
