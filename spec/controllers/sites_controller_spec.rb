require 'rails_helper'

describe SitesController do
  let(:site)    { create :site, abbr: 'moj' }
  let(:gds_bob) { create(:gds_editor, name: 'Bob Terwhilliger') }

  describe '#edit' do
    context 'when the user does have permission' do
      before do
        login_as gds_bob
      end

      it 'displays the form' do
        get :edit, params: { id: site.abbr }
        expect(response.status).to eql(200)
      end
    end

    context 'when the user does not have permission' do
      def make_request
        get :edit, params: { id: site.abbr }
      end

      it_behaves_like 'disallows editing by non-GDS Editors'
    end
  end

  context 'logged in' do
    before do
      login_as gds_bob
    end

    describe '#show' do
      it 'loads the site' do
        site = create :site
        get :show, params: { id: site.abbr }
        expect(assigns(:site)).to eq(site)
      end
    end

    describe '#new' do
      let(:organisation) { create :organisation }

      before do
        get :new, params: { organisation: organisation.whitehall_slug }
      end

      it 'assigns a new organisation' do
        expect(assigns(:site)).not_to be_nil
      end

      it 'new site has the correct organisation id' do
        expect(assigns(:site).organisation_id).to eq(organisation.id)
      end
    end

    describe '#create' do
      let(:organisation) { create :organisation }
      it 'creates a new site' do
        params = {
          organisation_id: organisation.id,
          launch_date: Time.zone.today + 10.days,
          abbr: 'MOJ',
          query_params: 'search=q',
          homepage: 'http://department.gov.uk',
          global_new_url: 'http://gov.uk/department',
          global_redirect_append_path: true,
          homepage_title: 'Deparment of M'
        }

        expect do
          post :create, params: { site: params, host_list: 'localhost' }
        end.to change { Site.all.count }.by(1)

        site = Site.find_by(abbr: 'MOJ')
        expect(site.launch_date).to eq(params[:launch_date])
        expect(site.abbr).to eq(params[:abbr])
        expect(site.query_params).to eq(params[:query_params])
        expect(site.homepage).to eq(params[:homepage])
        expect(site.global_new_url).to eq(params[:global_new_url])
        expect(site.global_redirect_append_path)
          .to eq(params[:global_redirect_append_path])
        expect(site.homepage_title).to eq(params[:homepage_title])
        expect(site.organisation).to eq(organisation)
      end
    end

    describe '#update' do
      let(:site) { create :site }

      it 'updates a site' do
        params = {
          launch_date: Time.zone.today + 10.days,
          abbr: 'MOJ',
          query_params: 'search=q',
          homepage: 'http://department.gov.uk',
          global_new_url: 'http://gov.uk/department',
          global_redirect_append_path: true,
          homepage_title: 'Deparment of M'
        }

        patch :update, params: { id: site.abbr, site: params }
        site.reload
        expect(site.launch_date).to eq(params[:launch_date])
        expect(site.abbr).to eq(params[:abbr])
        expect(site.query_params).to eq(params[:query_params])
        expect(site.homepage).to eq(params[:homepage])
        expect(site.global_new_url).to eq(params[:global_new_url])
        expect(site.global_redirect_append_path)
          .to eq(params[:global_redirect_append_path])
        expect(site.homepage_title).to eq(params[:homepage_title])
      end
    end
  end
end
