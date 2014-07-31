require 'spec_helper'

describe Organisation do
  describe 'relationships' do
    it { should have_many(:sites) }
    it { should have_many(:hosts).through(:sites) }
    it { should have_many(:mappings).through(:sites) }
  end

  describe 'validations' do
    it { should validate_presence_of(:whitehall_slug) }
    it 'ensures whitehall_slugs are unique' do
      create :organisation
      should validate_uniqueness_of(:whitehall_slug)
    end
  end

  describe 'leaderboard' do
    describe 'each organisation' do
      before do
        organisation = create :organisation, :with_site
        other_site = create :site, organisation: organisation
        create :mapping, site: organisation.sites.first, type: 'unresolved'
        create :mapping, site: organisation.sites.first
        create :mapping, site: other_site
        create :daily_hit_total, host: other_site.hosts.first, count: 159, http_status: '404'
        create :daily_hit_total, host: other_site.hosts.first, count: 91, http_status: '404', total_on: 31.days.ago
      end

      subject(:leaderboard) { Organisation.leaderboard }

      it 'returns an array of organisations' do
        leaderboard.first.should be_a Organisation
      end

      it 'adds a site count' do
        leaderboard.first.site_count.should eq(2)
      end

      it 'adds a total mapping count' do
        leaderboard.first.mappings_across_sites.should eq(3)
      end

      it 'adds an unresolved mapping count' do
        leaderboard.first.unresolved_mapping_count.should eq(1)
      end

      it 'adds a count of the errors in the last thirty days' do
        leaderboard.first.error_count.should eq(159)
      end
    end

    describe 'sorting the leaderboard' do
      before do
        organisation = create :organisation, :with_site
        create :mapping, site: organisation.sites.first, type: 'unresolved'
        create :daily_hit_total, host: organisation.sites.first.hosts.first, count: 132, http_status: '404'

        other_organisation = create :organisation, :with_site
        create :mapping, site: other_organisation.sites.first, type: 'unresolved'
        create :daily_hit_total, host: other_organisation.sites.first.hosts.first, count: 175, http_status: '404'
      end

      subject(:leaderboard) { Organisation.leaderboard }

      it 'orders them in descending order of error count' do
        leaderboard.first.error_count.should eq(175)
      end
    end
  end
end
