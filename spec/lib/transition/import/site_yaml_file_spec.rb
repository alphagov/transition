require 'spec_helper'
require 'transition/import/site_yaml_file'

describe Transition::Import::SiteYamlFile do
  context 'A redirector YAML file' do
    subject(:redirector_yaml_file) do
      Transition::Import::SiteYamlFile.load('spec/fixtures/sites/someyaml/ago.yml')
    end

    its(:abbr)           { should eql 'ago' }
    its(:whitehall_slug) { should eql 'attorney-generals-office' }
    it 'is not managed by transition - it doesn\'t have transition-sites in path' do
      redirector_yaml_file.should_not be_managed_by_transition
    end

    describe '#import!' do
      let(:ago) { build :organisation, whitehall_slug: 'attorney-generals-office' }

      before do
        Organisation.stub(:find_by_whitehall_slug).and_return(ago)
        redirector_yaml_file.import!
      end

      subject(:site) { Site.find_by_abbr('ago') }

      its(:launch_date)           { should eql(Date.new(2012, 12, 13)) }
      its(:tna_timestamp)         { should be_a(Time) }
      its(:homepage)              { should eql('https://www.gov.uk/government/organisations/attorney-generals-office') }
      its(:managed_by_transition) { should eql(false) }
      its(:organisation)          { should eql(ago)}
      it 'should get hosts including aka hosts' do
        hosts = %w{
          www.attorneygeneral.gov.uk
          aka.attorneygeneral.gov.uk
          www.attorney-general.gov.uk
          aka.attorney-general.gov.uk
          www.ago.gov.uk
          aka.ago.gov.uk
          www.lslo.gov.uk
          aka.lslo.gov.uk
        }
        site.hosts.pluck(:hostname).should eql(hosts)
      end

      describe 'updates' do
        before do
          redirector_yaml_file.import!
          Transition::Import::SiteYamlFile.load('spec/fixtures/sites/updates/ago.yml').import!
        end

        its(:launch_date)           { should eql(Date.new(2014, 12, 13)) }
        its(:tna_timestamp)         { should be_a(Time) }
        its(:homepage)              { should eql('https://www.gov.uk/government/organisations/attorney-update-office') }
      end
    end
  end

  context 'A transition YAML file' do
    subject(:transition_yaml_file) do
      Transition::Import::SiteYamlFile.load('spec/fixtures/sites/someyaml/transition-sites/ukti.yml')
    end

    its(:abbr)           { should eql 'ukti' }
    its(:whitehall_slug) { should eql 'uk-trade-investment' }

    it 'is managed by transition - it has transition-sites in path' do
      transition_yaml_file.should be_managed_by_transition
    end
  end
end
