require 'spec_helper'
require 'gds-sso/lint/user_spec'

describe User do
  it_behaves_like "a gds-sso user class"

  describe 'organisation' do
    context 'user has no organisation set' do
      subject(:user) { create(:user, organisation_content_id: nil) }

      describe '#own_organisation' do
        subject { super().own_organisation }
        it { is_expected.to eql(nil) }
      end
    end

    context 'user has an organisation slug set' do
      content_id = SecureRandom.uuid
      let(:ministry_of_funk) { create(:organisation, content_id: content_id) }
      subject(:user) { create(:user, organisation_content_id: ministry_of_funk.content_id) }

      describe '#own_organisation' do
        subject { super().own_organisation }
        it { is_expected.to eql(ministry_of_funk) }
      end
    end

    context 'user has an organisation set that we don\'t have' do
      subject(:user) { create(:user, organisation_content_id: SecureRandom.uuid) }

      describe '#own_organisation' do
        subject { super().own_organisation }
        it { is_expected.to eql(nil) }
      end
    end
  end

  describe 'gds_editor?' do
    context 'doesn\'t have permission' do
      subject(:user) { create(:user, permissions: ["signin"])}

      describe '#gds_editor?' do
        subject { super().gds_editor? }
        it { is_expected.to be_falsey }
      end
    end

    context 'has relevant permission' do
      subject(:user) { create(:gds_editor) }

      describe '#gds_editor?' do
        subject { super().gds_editor? }
        it { is_expected.to be_truthy }
      end
    end
  end

  describe 'can_edit_site?' do
    let(:ministry_of_funk) { create(:organisation) }
    let(:agency_of_soul)   { create(:organisation, parent_organisations: [ministry_of_funk]) }

    context 'user is an gds_editor' do
      let(:generic_site) { create(:site) }
      subject(:user)     { create(:gds_editor) }

      it 'lets them edit anything' do
        expect(user.can_edit_site?(generic_site)).to be_truthy
      end
    end

    context 'user is not a member of any organisation' do
      let(:generic_site) { create(:site) }
      subject(:user)     { create(:user) }

      specify { expect(user.can_edit_site?(generic_site)).to be_falsey }
    end

    context 'an organisation is a primary owner of a site' do
      context 'user is a member of the organisation' do
        let(:site)     { create(:site, organisation: ministry_of_funk) }
        subject(:user) { create(:user, organisation_content_id: ministry_of_funk.content_id) }

        specify { expect(user.can_edit_site?(site)).to be_truthy }
      end

      context 'user is a member of a parent organisation' do
        let(:site_of_child) { create(:site, organisation: agency_of_soul) }
        subject(:user)      { create(:user, organisation_content_id: ministry_of_funk.content_id) }

        specify { expect(user.can_edit_site?(site_of_child)).to be_truthy }
      end

      context 'user is a member of a child organisation' do
        let(:site_of_parent) { create(:site, organisation: ministry_of_funk) }
        subject(:user)       { create(:user, organisation_content_id: agency_of_soul.content_id) }

        specify { expect(user.can_edit_site?(site_of_parent)).to be_falsey }
      end

      context 'user is a member of one parent organisation and not a member of another parent' do
        let!(:department_of_disco) {
          create(:organisation, child_organisations: [agency_of_soul])
        }
        let(:site_of_child) { create(:site, organisation: agency_of_soul) }
        subject(:user)      { create(:user, organisation_content_id: ministry_of_funk.content_id) }

        specify { expect(user.can_edit_site?(site_of_child)).to be_truthy }
      end
    end

    context 'the site has extra organisations whose members can edit it' do
      let(:shoe_procurement_bureau) { create(:organisation) }
      let(:soulless_agency)         { create(:organisation) }
      let(:site)                    { create(:site, organisation: agency_of_soul,
                                             extra_organisations: [shoe_procurement_bureau, soulless_agency]) }

      context 'user is a member of an extra organisation' do
        subject(:user) { create(:user, organisation_content_id: shoe_procurement_bureau.content_id) }

        specify { expect(user.can_edit_site?(site)).to be_truthy }
      end

      context 'user is a member of an extra organisation\'s parent' do
        let(:ministry_of_silly_walks)   { create(:organisation) }
        subject(:user)                  { create(:user, organisation_content_id: ministry_of_silly_walks.content_id) }

        specify { expect(user.can_edit_site?(site)).to be_falsey }
      end
    end
  end
end
