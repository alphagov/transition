require 'rails_helper'

describe OrganisationsController do
  before do
    login_as_stub_user
  end

  describe '#index' do
    let(:organisation_z) { create :organisation, :with_site, title: 'Zzzzzz' }
    let(:organisation_a) { create :organisation, :with_site, title: 'Aaaaaa' }

    it 'orders organisations alphabetically' do
      get :index
      expect(assigns(:organisations)).to eq([organisation_a, organisation_z])
    end
  end

  describe '#show' do
    let(:organisation) { create :organisation }
    it 'sets the organisation' do
      get :show, params: { id: organisation.whitehall_slug }
      expect(assigns(:organisation)).to eq(organisation)
    end
  end

  describe '#new' do
    it 'creates an organisation' do
      get :new
      expect(assigns(:organisation)).not_to be_nil
    end
  end

  describe '#edit' do
    let(:organisation) { create :organisation }
    it 'loads the organisation for editing' do
      get :edit, params: { id: organisation.whitehall_slug }
      expect(assigns(:organisation)).to eq(organisation)
    end
  end

  describe '#create' do
    it 'creates a new organisation' do
      params = {
        title: 'New Organisation',
        homepage: 'http://example.com',
        whitehall_slug: 'example-com',
        whitehall_type: 'Site',
        abbreviation: 'SEC'
      }
      expect { post :create, params: { organisation: params } }
        .to change { Organisation.all.count }.by(1)
    end
  end

  describe '#edit' do
    let(:organisation) { create :organisation }

    it 'updates an organisation' do
      params = {
        title: 'Updated Organisation',
        homepage: 'http://example.com',
        whitehall_slug: 'example-com',
        whitehall_type: 'Site',
        abbreviation: 'SEC'
      }
      patch :update, params: {
        id: organisation.whitehall_slug, organisation: params
      }
      organisation.reload
      expect(organisation.title).to eq(params[:title])
      expect(organisation.homepage).to eq(params[:homepage])
      expect(organisation.whitehall_slug).to eq(params[:whitehall_slug])
      expect(organisation.whitehall_type).to eq(params[:whitehall_type])
      expect(organisation.abbreviation).to eq(params[:abbreviation])
    end
  end
end
