require 'spec_helper'
require 'transition/import/orgs_sites_hosts'

describe Transition::Import::OrgsSitesHosts do
  describe '.from_redirector_yaml!' do

    context 'there are no valid yaml files' do
      it 'reports the lack' do
        lambda do
          Transition::Import::OrgsSitesHosts.from_redirector_yaml!('spec/fixtures/sites/noyaml/*.yml')
        end.should raise_error(Transition::Import::OrgsSitesHosts::NoYamlFound)
      end
    end

    context 'importing valid yaml files', testing_before_all: true do
      before :all do
        Transition::Import::OrgsSitesHosts.from_redirector_yaml!('spec/fixtures/sites/someyaml/*.yml')
        @businesslink = Organisation.find_by_abbr!('businesslink')
      end

      it 'has imported orgs' do
        Organisation.count.should == 4
      end

      it 'has imported sites' do
        Site.count.should == 6
      end

      it 'has imported hosts' do
        Host.count.should == 18
      end

      describe 'a department' do
        it 'has assigned an organisation to its own site' do
          Site.find_by_abbr!('businesslink').organisation.should == @businesslink
        end
      end

      describe 'a child organisation with its own hosted site' do
        let(:bis) { Organisation.find_by_abbr! 'bis' }

        subject { Organisation.find_by_abbr! 'ukaea' }

        it { should have(1).site }
        its(:parent) { should eql bis }
      end

      describe 'a child site that is not an organisation' do
        it 'has assigned the right parent org' do
          Site.find_by_abbr!('businesslink_events').organisation.should == @businesslink
        end
      end

      describe 'The Wales office breaking case' do
        it 'does not create a new org for the same title in a different language' do
          Organisation.find_by_abbr('walesoffice_cymru').should be_nil
        end
      end
    end
  end
end
