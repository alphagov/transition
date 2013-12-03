require 'spec_helper'
require 'transition/import/orgs_sites_hosts'

describe Transition::Import::OrgsSitesHosts do
  describe '.from_redirector_yaml!' do

    context 'there are no valid yaml files' do
      it 'reports the lack' do
        expect {
          Transition::Import::OrgsSitesHosts.from_redirector_yaml!(
            'spec/fixtures/sites/noyaml/*.yml',
            Transition::Import::WhitehallOrgs.new('spec/fixtures/whitehall/orgs_abridged.yml')
          )
        }.to raise_error(Transition::Import::Sites::NoYamlFound)
      end
    end

    context 'importing valid yaml files', testing_before_all: true do
      before :all do
        Transition::Import::OrgsSitesHosts.from_redirector_yaml!(
          'spec/fixtures/sites/someyaml/**/*.yml',
          Transition::Import::WhitehallOrgs.new('spec/fixtures/whitehall/orgs_abridged.yml')
        )
        @ukti = Site.find_by_abbr('ukti')
      end

      it 'has imported orgs' do
        Organisation.count.should == 8
      end

      it 'has imported sites' do
        Site.count.should == 11
      end

      it 'has imported hosts' do
        Host.count.should == 35
      end

      it 'sets managed_by_transition to false for sites not in transition-sites' do
        Site.where(managed_by_transition: true).should == [@ukti]
      end

      ##
      # BusinessLink and Directgov never existed in Whitehall.
      describe 'sites with organisations that sort of don\'t exist' do
        let(:businesslink) { Organisation.find_by_whitehall_slug('business-link') }
        let(:directgov)    { Organisation.find_by_whitehall_slug('directgov') }

        it 'has assigned sites to businesslink' do
          Site.find_by_abbr!('businesslink').organisation.should == businesslink
          Site.find_by_abbr!('businesslink_events').organisation.should == businesslink
        end
        it 'has assigned sites to Directgov' do
          Site.find_by_abbr!('directgov').organisation.should == directgov
          Site.find_by_abbr!('directgov_campaigns').organisation.should == directgov
        end
      end

      describe 'a child organisation with its own hosted site' do
        let(:bis) { Organisation.find_by_whitehall_slug! 'department-for-business-innovation-skills' }

        subject { Organisation.find_by_whitehall_slug! 'uk-atomic-energy-authority' }

        it                         { should have(1).site }
        its(:parent_organisations) { should eql [bis] }
        its(:abbreviation)         { should eql 'UKAEA' }
        its(:whitehall_type)       { should eql 'Executive non-departmental public body' }
      end

      context 'the import is run again' do
        before :all do
          Transition::Import::OrgsSitesHosts.from_redirector_yaml!(
            'spec/fixtures/sites/someyaml/*.yml',
            Transition::Import::WhitehallOrgs.new('spec/fixtures/whitehall/orgs_abridged.yml')
          )
        end

        describe 'a pre-existing parent-child relationship is not duplicated' do
          let(:bis) { Organisation.find_by_whitehall_slug! 'department-for-business-innovation-skills' }

          subject { Organisation.find_by_whitehall_slug! 'uk-atomic-energy-authority' }

          its(:parent_organisations) { should have_exactly(1).organisations }
          its(:parent_organisations) { should eql [bis] }
        end
      end
    end
  end
end
