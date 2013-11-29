require 'spec_helper'
require 'transition/import/orgs_sites_hosts'

describe Transition::Import::OrgsSitesHosts do
  describe '.from_redirector_yaml!' do

    context 'there are no valid yaml files' do
      it 'reports the lack' do
        expect {
          Transition::Import::OrgsSitesHosts.from_redirector_yaml!('spec/fixtures/sites/noyaml/*.yml')
        }.to raise_error(Transition::Import::OrgsSitesHosts::NoYamlFound)
      end
    end

    context 'importing valid yaml files', testing_before_all: true do
      before :all do
        @old_site = create(:site, abbr: 'oldsite')
        # This nasty block is a substitute for stubbing, which isn't available in a before :all
        Transition::Import::OrgsSitesHosts.from_redirector_yaml!('spec/fixtures/sites/someyaml/*.yml') do |o|
          def o.whitehall_organisations
            Transition::Import::WhitehallOrgs.new.tap do |orgs|
              def orgs.cached_org_path
                'spec/fixtures/whitehall/orgs.yml'
              end
            end
          end
        end

        @businesslink = Organisation.find_by_redirector_abbr!('businesslink')
      end

      it 'has imported orgs' do
        Organisation.count.should == 5
      end

      it 'has imported sites' do
        Site.count.should == 7
      end

      it 'has imported hosts' do
        Host.count.should == 18
      end

      it 'sets managed_by_transition to false for all new sites' do
        Site.where(managed_by_transition: true).should == [@old_site]
      end

      describe 'a department' do
        it 'has assigned an organisation to its own site' do
          Site.find_by_abbr!('businesslink').organisation.should == @businesslink
        end
      end

      describe 'a child organisation with its own hosted site' do
        let(:bis) { Organisation.find_by_redirector_abbr! 'bis' }

        subject { Organisation.find_by_redirector_abbr! 'ukaea' }

        it                   { should have(1).site }
        its(:parent_organisations) { should eql [bis] }
        its(:abbreviation)   { should eql 'UKAEA' }
        its(:whitehall_slug) { should eql 'uk-atomic-energy-authority' }
        its(:whitehall_type) { should eql 'Executive non-departmental public body' }
      end

      describe 'a child site that is not an organisation' do
        it 'has assigned the right parent org' do
          Site.find_by_abbr!('businesslink_events').organisation.should == @businesslink
        end
      end

      describe 'The Wales office breaking case' do
        it 'does not create a new org for the same title in a different language' do
          Organisation.find_by_redirector_abbr('walesoffice_cymru').should be_nil
        end
      end

      context 'the import is run again' do
        before :all do
          Transition::Import::OrgsSitesHosts.from_redirector_yaml!('spec/fixtures/sites/someyaml/*.yml') do |o|
            def o.whitehall_organisations
              Transition::Import::WhitehallOrgs.new.tap do |orgs|
                def orgs.cached_org_path
                  'spec/fixtures/whitehall/orgs.yml'
                end
              end
            end
          end
        end

        describe 'a pre-existing parent-child relationship is not duplicated' do
          let(:bis) { Organisation.find_by_redirector_abbr! 'bis' }

          subject { Organisation.find_by_redirector_abbr! 'ukaea' }

          its(:parent_organisations) { should have_exactly(1).organisations }
          its(:parent_organisations) { should eql [bis] }
        end
      end
    end
  end
end
