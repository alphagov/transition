require 'spec_helper'
require 'transition/import/whitehall_orgs'

describe Transition::Import::WhitehallOrgs do
  context 'with an API response stubbed to fixtures' do
    subject(:whitehall_orgs) do
      Transition::Import::WhitehallOrgs.new.tap do |orgs|
        orgs.stub(:cached_org_path).and_return('spec/fixtures/whitehall/orgs.yml')
      end
    end

    it { should have(2).organisations }

    describe 'indexing [] by title' do
      subject(:ago) do
        whitehall_orgs.by_title['Attorney General\'s Office']
      end

      it                   { should be_an(OpenStruct) }
      specify              { ago.format.should == 'Ministerial department' }
      its(:'details.slug') { should == 'attorney-generals-office' }
    end
  end
end
