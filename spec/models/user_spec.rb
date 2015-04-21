require 'spec_helper'
require 'gds-sso/lint/user_spec'

describe User do
  it_behaves_like "a gds-sso user class"

  describe 'organisation' do
    context 'user has no organisation slug set' do
      subject(:user) { create(:user, organisation_slug: nil) }

      its(:own_organisation) { should eql(nil) }
    end

    context 'user has an organisation slug set' do
      subject(:user) { create(:user, organisation_slug: "ministry-of-funk") }
      let(:ministry_of_funk) { create(:organisation, whitehall_slug: "ministry-of-funk") }

      its(:own_organisation) { should eql(ministry_of_funk) }
    end

    context 'user has an organisation slug set that we don\'t have' do
      subject(:user) { create(:user, organisation_slug: "nasa") }

      its(:own_organisation) { should eql(nil) }
    end
  end

  describe 'gds_editor?' do
    context 'doesn\'t have permission' do
      subject(:user) { create(:user, permissions: ["signin"])}

      its(:gds_editor?) { should be_false }
    end

    context 'has relevant permission' do
      subject(:user) { create(:gds_editor) }

      its(:gds_editor?) { should be_true }
    end
  end

  describe 'can_edit_site?' do
    let(:ministry_of_funk) { create(:organisation, whitehall_slug: "ministry-of-funk") }
    let(:agency_of_soul)   { create(:organisation, whitehall_slug: "agency-of-soul", parent_organisations: [ministry_of_funk]) }

    context 'user is an gds_editor' do
      let(:generic_site) { create(:site) }
      subject(:user)     { create(:gds_editor) }

      it 'lets them edit anything' do
        user.can_edit_site?(generic_site).should be_true
      end
    end

    context 'user is not a member of any organisation' do
      let(:generic_site) { create(:site) }
      subject(:user)     { create(:user) }

      specify { user.can_edit_site?(generic_site).should be_false }
    end

    context 'an organisation is a primary owner of a site' do
      context 'user is a member of the organisation' do
        let(:site)     { create(:site, organisation: ministry_of_funk) }
        subject(:user) { create(:user, organisation_slug: ministry_of_funk.whitehall_slug) }

        specify { user.can_edit_site?(site).should be_true }
      end

      context 'user is a member of a parent organisation' do
        let(:site_of_child) { create(:site, organisation: agency_of_soul) }
        subject(:user)      { create(:user, organisation_slug: ministry_of_funk.whitehall_slug) }

        specify { user.can_edit_site?(site_of_child).should be_true }
      end

      context 'user is a member of a child organisation' do
        let(:site_of_parent) { create(:site, organisation: ministry_of_funk) }
        subject(:user)       { create(:user, organisation_slug: agency_of_soul.whitehall_slug) }

        specify { user.can_edit_site?(site_of_parent).should be_false }
      end

      context 'user is a member of one parent organisation and not a member of another parent' do
        let!(:department_of_disco) {
          create(:organisation, whitehall_slug: "department-of-disco", child_organisations: [agency_of_soul])
        }
        let(:site_of_child) { create(:site, organisation: agency_of_soul) }
        subject(:user)      { create(:user, organisation_slug: ministry_of_funk.whitehall_slug) }

        specify { user.can_edit_site?(site_of_child).should be_true }
      end
    end

    context 'the site has extra organisations whose members can edit it' do
      let(:shoe_procurement_bureau) { create(:organisation, whitehall_slug: "shoe-procurement-bureau") }
      let(:soulless_agency)         { create(:organisation, whitehall_slug: "soulless-agency") }
      let(:site)                    { create(:site, organisation: agency_of_soul,
                                             extra_organisations: [shoe_procurement_bureau, soulless_agency]) }

      context 'user is a member of an extra organisation' do
        subject(:user) { create(:user, organisation_slug: shoe_procurement_bureau.whitehall_slug) }

        specify { user.can_edit_site?(site).should be_true }
      end

      context 'user is a member of an extra organisation\'s parent' do
        let(:ministry_of_silly_walks)   { create(:organisation, whitehall_slug: "ministry-of-silly-walks") }
        subject(:user)                  { create(:user, organisation_slug: ministry_of_silly_walks.whitehall_slug) }

        specify { user.can_edit_site?(site).should be_false }
      end
    end
  end
end
