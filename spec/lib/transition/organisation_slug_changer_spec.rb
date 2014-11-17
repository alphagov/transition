require 'spec_helper'

module Transition
  describe OrganisationSlugChanger do
    let(:old_slug)      { 'old-slug' }
    let(:new_slug)      { 'new-slug' }

    subject(:slug_changer) {
      OrganisationSlugChanger.new(old_slug, new_slug)
    }

    context "no matching organisation exists" do
      it 'returns false' do
        expect(slug_changer.call).to eq(false)
      end
    end

    context "an matching organisation exists" do
      let!(:organisation) { create(:organisation, whitehall_slug: old_slug) }

      it 'returns true' do
        expect(slug_changer.call).to eq(true)
      end

      it 'updates the slug of the organisation' do
        slug_changer.call

        expect(organisation.reload.whitehall_slug).to eq(new_slug)
      end

      context "with an associated user" do
        let!(:user) { create(:user, organisation_slug: old_slug) }

        it 'updates the organisation_slug of the user' do
          slug_changer.call

          expect(user.reload.organisation_slug).to eq(new_slug)
        end
      end
    end
  end
end
