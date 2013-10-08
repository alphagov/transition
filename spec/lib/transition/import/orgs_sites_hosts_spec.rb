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
        # There are 2 orgs, 3 sites and 15 hosts.
        # We'll need a more representative sample for partial domains
        Transition::Import::OrgsSitesHosts.from_redirector_yaml!('spec/fixtures/sites/someyaml/*.yml')
        @businesslink = Organisation.find_by_abbr!('businesslink')
      end

      it 'has imported orgs' do
        Organisation.count.should == 2
      end

      it 'has assigned an org id to an org site' do
        Site.find_by_abbr!('businesslink').organisation.should == @businesslink
      end

      it 'has assigned a parent org id to a child site' do
        Site.find_by_abbr!('businesslink_events').organisation.should == @businesslink
      end

      it 'has imported sites' do
        Site.count.should == 3
      end

      it 'has imported hosts' do
        Host.count.should == 15
      end
    end

  end
end
