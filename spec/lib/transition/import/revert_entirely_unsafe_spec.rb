require 'spec_helper'
require 'transition/import/revert_entirely_unsafe'

describe Transition::Import::RevertEntirelyUnsafe::RevertSite do
  describe '#revert_all_data!' do
    before do
      @bona_vacantia = create :organisation, whitehall_slug: 'bona-vacantia'
      @treasury_office = create :organisation, whitehall_slug: 'treasury-solicitor-s-office'
      Transition::Import::OrgsSitesHosts.from_yaml!(
        'spec/fixtures/sites/someyaml/**/*.yml',
        Transition::Import::WhitehallOrgs.new('spec/fixtures/whitehall/orgs_abridged.yml')
      )

      @site_abbr = 'ago'
      @ago = Site.find_by(abbr: @site_abbr)
      create :mapping, site: @ago

      @original_site_count = 8
      @original_host_count = 24
      @extra_sites_count = 2

      Site.count.should eql(@original_site_count)
      Host.count.should eql(@original_host_count)
      @bona_vacantia.extra_sites.count.should eql(1)
      @treasury_office.extra_sites.count.should eql(1)

      @ago.extra_organisations.count.should eql(@extra_sites_count)
      @ago.mappings.count.should eql(1)

      @ago.hosts.each do |ago_host|
        create :hit, host: ago_host
        create :host_path, host: ago_host
        create :daily_hit_total, host: ago_host
        ago_host.hits.count.should eql(1)
        ago_host.host_paths.count.should eql(1)
        ago_host.daily_hit_totals.count.should eql(1)
      end

      @host_names = %w(
        www.attorneygeneral.gov.uk
        aka.attorneygeneral.gov.uk
        www.attorney-general.gov.uk
        aka.attorney-general.gov.uk
        www.ago.gov.uk
        aka.ago.gov.uk
        www.lslo.gov.uk
        aka.lslo.gov.uk
      )
    end

    context 'delete the site and all data' do
      before do
        Transition::Import::RevertEntirelyUnsafe::RevertSite.new(@ago).revert_all_data!
      end

      it 'should only have deleted the site passed in' do
        Site.count.should eql(7)
        Site.where(abbr: @site_abbr).should be_empty
        Site.where(abbr: 'bis').should exist
      end

      it 'should have deleted the hosts' do
        Host.count.should eql(16)
        @host_names.each do |host|
          Host.find_by(hostname: host).should be_nil
        end
      end

      it 'should have deleted the mappings' do
        @ago.mappings.count.should eql(0)
      end

      it 'should have deleted all the hits' do
        @ago.hosts.each do |host|
          host.hits.count.should eql(0)
        end
      end

      it 'should have deleted all the host_paths' do
        @ago.hosts.each do |host|
          host.host_paths.count.should eql(0)
        end
      end

      it 'should have deleted all the daily_hit_totals' do
        @ago.hosts.each do |host|
          host.daily_hit_totals.should eql(0)
        end
      end

      it 'should have deleted the sites\' links to extra organisations' do
        @ago.extra_organisations.count.should eql(0)
      end
    end

  end
end
