require 'spec_helper'

describe ErrorsController do
  # This controller does not require authentication so its views must not
  # require a logged-in user, so render them to make sure that no further
  # exceptions are generated
  render_views

  shared_examples 'a JSON error' do
    it 'responds with JSON' do
      expect(response.content_type.to_s).to eql('application/json')
    end

    it 'has a status of "error" in the body' do
      expect(@parsed_response['_response_info']['status']).to eql('error')
    end
  end

  describe '#error_404' do
    before do
      get :error_404
    end

    it 'responds with the correct HTTP status code' do
      expect(response.status).to be(404)
    end

    it 'renders our custom error page' do
      expect(response).to render_template 'errors/error_404'
    end

    it 'uses the error page layout' do
      expect(response).to render_template 'layouts/error_page'
    end

    it 'includes the friendly message' do
      expect(response.body).to include('Please check that you have entered the correct web address')
    end

    context 'when requesting JSON' do
      before do
        get :error_404, format: 'json'
        @parsed_response = JSON.parse(response.body)
      end

      it_behaves_like 'a JSON error'

      it 'responds with the correct HTTP status code' do
        expect(response.status).to be(404)
      end
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
      expect(response).to render_template 'errors/error_422'
    end

    it 'uses the error page layout' do
      expect(response).to render_template 'layouts/error_page'
    end

    it 'includes the friendly message' do
      expect(HTMLEntities.new.decode(response.body)).to include('Maybe you tried to change something you didn\'t have access to.')
    end

    context 'when requesting JSON' do
      before do
        get :error_422, format: 'json'
        @parsed_response = JSON.parse(response.body)
      end

      it_behaves_like 'a JSON error'

      it 'responds with the correct HTTP status code' do
        expect(response.status).to be(422)
      end
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
      expect(response).to render_template 'errors/error_500'
    end

    it 'uses the error page layout' do
      expect(response).to render_template 'layouts/error_page'
    end

    it 'includes the friendly message' do
      expect(response.body).to include('sorry, something went wrong')
    end

    context 'when requesting JSON' do
      before do
        get :error_500, format: 'json'
        @parsed_response = JSON.parse(response.body)
      end

      it_behaves_like 'a JSON error'

      it 'responds with the correct HTTP status code' do
        expect(response.status).to be(500)
      end
    end
  end
end
