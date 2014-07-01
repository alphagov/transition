require 'spec_helper'
require 'transition/import/site_yaml_file'

describe Transition::Import::SiteYamlFile do
  context 'A redirector YAML file' do
    subject(:redirector_yaml_file) do
      Transition::Import::SiteYamlFile.load('spec/fixtures/sites/someyaml/ago.yml')
    end

    its(:abbr)           { should eql 'ago' }
    its(:whitehall_slug) { should eql 'attorney-generals-office' }
    its(:extra_organisation_slugs) { should eql(['bona-vacantia', 'treasury-solicitor-s-office']) }

    describe '#import!' do
      let(:ago)  { build :organisation, whitehall_slug: 'attorney-generals-office' }
      let(:bv)   { build :organisation, whitehall_slug: 'bona-vacantia' }
      let(:tsol) { build :organisation, whitehall_slug: 'treasury-solicitor-s-office' }

      before do
        Organisation.stub(:find_by_whitehall_slug).and_return(ago)
        Organisation.stub(:where).and_return([bv, tsol])
        redirector_yaml_file.import!
      end

      subject(:site) { Site.find_by_abbr('ago') }

      its(:tna_timestamp)         { should be_a(Time) }
      its(:homepage)              { should eql('https://www.gov.uk/government/organisations/attorney-generals-office') }
      its(:homepage_furl)         { should eql('www.gov.uk/ago') }
      its(:organisation)          { should eql(ago) }
      its(:extra_organisations)   { should =~ [bv, tsol] }
      its(:global_type)           { should eql('redirect') }
      its(:global_new_url)        { should eql('https://www.gov.uk/a-new-world') }
      its(:global_redirect_append_path) { should eql(true) }
      its(:special_redirect_strategy) { should be_nil }

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
        site.hosts.pluck(:hostname).sort.should eql(hosts.sort)
      end

      describe 'updates' do
        before do
          redirector_yaml_file.import!
          Organisation.stub(:where).and_return([tsol])
          Transition::Import::SiteYamlFile.load('spec/fixtures/sites/updates/ago.yml').import!
          Transition::Import::SiteYamlFile.load('spec/fixtures/sites/updates/ago_lslo.yml').import!
        end

        its(:tna_timestamp)         { should be_a(Time) }
        its(:homepage)              { should eql('https://www.gov.uk/government/organisations/attorney-update-office') }
        its(:homepage_title)        { should eql('Now has a &#39;s custom title') }
        its(:extra_organisations)   { should =~ [tsol] }
        its(:global_type)           { should be_nil }
        its(:global_new_url)        { should be_nil }
        its(:global_redirect_append_path) { should eql(false) }
        its(:special_redirect_strategy) { should eql('via_aka') }

        it 'should move the host and the aka host to the new site' do
          site.hosts.pluck(:hostname).should_not include('www.lslo.gov.uk')
          ago_lslo = Site.find_by_abbr('ago_lslo')
          ago_lslo.hosts.pluck(:hostname).should =~ ['www.lslo.gov.uk', 'aka.lslo.gov.uk']
        end
      end
    end
  end

  context 'A transition YAML file' do
    subject(:transition_yaml_file) do
      Transition::Import::SiteYamlFile.load('spec/fixtures/sites/someyaml/transition-sites/ukti.yml')
    end

    its(:abbr)           { should eql 'ukti' }
    its(:whitehall_slug) { should eql 'uk-trade-investment' }
  end
end
