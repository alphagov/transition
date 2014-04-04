require 'spec_helper'

describe OrganisationsController do
  describe '#index' do

    let!(:organisation_z) { create :organisation, :with_site, title: 'Zzzzzz' }
    let!(:organisation_a) { create :organisation, :with_site, title: 'Aaaaaa' }

    before do
      login_as_stub_user
      get :index
    end

    it 'orders organisations alphabetically' do
      assigns(:organisations).should == [organisation_a, organisation_z]
    end
  end

  describe '#show' do
    render_views
    let!(:organisation)            { create :organisation }
    let!(:shoe_procurement_bureau) { create :site, organisation: organisation,
                                    abbr: 'spb' }
    let!(:agency_of_sole)          { create :site, abbr: 'aos' }

    before do
      organisation.extra_sites = [agency_of_sole]
      login_as_stub_user
      get :show, id: organisation.whitehall_slug
    end

    it 'shows the organisation\'s own site (the Shoe Procurement Bureau)' do
      expect(response.body).to have_selector('.sites tbody tr:last-child td:first-child',
                                             text: 'spb.gov.uk')
    end

    it 'shows other sites the organisation can edit (through extra_sites)' do
      # For example the Agency of Sole.
      expect(response.body).to have_selector('.sites tbody tr:first-child td:first-child',
                                             text: "aos.gov.uk\n            owned by\n            Orgtastic")
    end
  end
end
