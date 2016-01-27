shared_examples 'disallows editing by unaffiliated user' do
  before do
    login_as stub_user
    make_request
  end

  it 'redirects to the index page' do
    expect(response).to redirect_to site_mappings_path(site)
  end

  it 'sets a flash message' do
    expect(flash[:alert]).to include('don\'t have permission to edit')
  end
end

shared_examples 'disallows editing by non-GDS Editors' do
  before do
    login_as stub_user
    make_request
  end

  it 'redirects to the index page' do
    expect(response).to redirect_to site_path(site)
  end

  it 'sets a flash message' do
    expect(flash[:alert]).to eql('Only GDS Editors can access that.')
  end
end
