require 'spec_helper'

describe StaticContentController do
  # This controller does not require authentication so its views must not
  # require a logged-in user, so render them to make sure there are no errors
  render_views

  describe '#error_404' do
    before do
      get :error_404
    end

    it 'responds with the correct HTTP status code' do
      expect(response.status).to be(404)
    end

    it 'renders our custom error page' do
      expect(response).to render_template 'static_content/error_404'
    end

    it 'uses the error page layout' do
      expect(response).to render_template 'layouts/error_page'
    end

    it 'includes the friendly message' do
      expect(response.body).to include('Please check that you have entered the correct web address')
    end
  end

  describe '#error_422' do
    before do
      get :error_422
    end

    it 'responds with the correct HTTP status code' do
      expect(response.status).to be(422)
    end

    it 'renders our custom error page' do
      expect(response).to render_template 'static_content/error_422'
    end

    it 'uses the error page layout' do
      expect(response).to render_template 'layouts/error_page'
    end

    it 'includes the friendly message' do
      expect(response.body).to include('Maybe you tried to change something you didn\'t have access to.')
    end
  end

  describe '#error_500' do
    before do
      get :error_500
    end

    it 'responds with the correct HTTP status code' do
      expect(response.status).to be(500)
    end

    it 'renders our custom error page' do
      expect(response).to render_template 'static_content/error_500'
    end

    it 'uses the error page layout' do
      expect(response).to render_template 'layouts/error_page'
    end

    it 'includes the friendly message' do
      expect(response.body).to include('sorry, something went wrong')
    end
  end
end
