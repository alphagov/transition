module AuthenticationControllerHelpers
  def login_as(user)
    request.env['warden'] = stub(
      :authenticate! => true,
      :authenticated? => true,
      :user => user
    )
  end

  def stub_user
    create(:user)
  end

  def login_as_stub_user
    login_as stub_user
  end

  shared_examples 'disallows editing by unaffiliated user' do
    before do
      login_as stub_user
      make_request
    end

    it 'redirects to the index page' do
      expect(response).to redirect_to site_mappings_path(site)
    end

    it 'sets a flash message' do
      flash[:alert].should include('don\'t have permission to edit')
    end
  end
end
RSpec.configuration.include AuthenticationControllerHelpers, :type => :controller
