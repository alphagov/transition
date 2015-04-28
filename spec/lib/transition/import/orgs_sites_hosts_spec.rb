require 'spec_helper'
require 'transition/import/orgs_sites_hosts'

describe Transition::Import::OrgsSitesHosts do
  describe '.from_yaml!' do

    context 'there are no valid yaml files' do
      it 'reports the lack' do
        expect {
          Transition::Import::OrgsSitesHosts.from_yaml!(
            'spec/fixtures/sites/noyaml/*.yml',
            Transition::Import::WhitehallOrgs.new('spec/fixtures/whitehall/orgs_abridged.yml')
          )
        }.to raise_error(Transition::Import::Sites::NoYamlFound)
      end
    end

    context 'importing valid yaml files', testing_before_all: true do
      before :all do
        Transition::Import::OrgsSitesHosts.from_yaml!(
          'spec/fixtures/sites/someyaml/**/*.yml',
          Transition::Import::WhitehallOrgs.new('spec/fixtures/whitehall/orgs_abridged.yml')
        )
        @ukti = Site.find_by_abbr('ukti')
      end

      it 'has imported orgs' do
        Organisation.count.should == 6
      end

      it 'has imported sites' do
        Site.count.should == 8
      end

      it 'has imported hosts' do
        Host.count.should == (12 * 2) # 12 hosts plus 12 aka hosts
      end

      describe 'a child organisation with its own hosted site' do
        let(:bis) { Organisation.find_by_whitehall_slug! 'department-for-business-innovation-skills' }

        subject { Organisation.find_by_whitehall_slug! 'uk-atomic-energy-authority' }

        it                         { should have(1).site }
        its(:parent_organisations) { should =~ [bis] }
        its(:abbreviation)         { should eql 'UKAEA' }
        its(:whitehall_type)       { should eql 'Executive non-departmental public body' }
      end

      context 'the import is run again' do
        before :all do
          Transition::Import::OrgsSitesHosts.from_yaml!(
            'spec/fixtures/sites/someyaml/*.yml',
            Transition::Import::WhitehallOrgs.new('spec/fixtures/whitehall/orgs_abridged.yml')
          )
        end

        describe 'a pre-existing parent-child relationship is not duplicated' do
          let(:bis) { Organisation.find_by_whitehall_slug! 'department-for-business-innovation-skills' }

          subject { Organisation.find_by_whitehall_slug! 'uk-atomic-energy-authority' }

          its(:parent_organisations) { should have_exactly(1).organisations }
          its(:parent_organisations) { should =~ [bis] }
        end
      end
    end
  end
end
