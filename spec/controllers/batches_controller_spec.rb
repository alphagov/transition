require 'spec_helper'

describe BatchesController do
  describe 'GET #show' do
    let(:user) { create(:user) }
    let(:site) { create(:site) }

    before do
      login_as(user)
      get :show, site_id: site.abbr, id: batch_id
      @parsed_response = JSON.parse(response.body)
    end

    context 'when the batch exists' do
      let(:batch_id) { create(:bulk_add_batch, site: site, user: user).id }

      it 'responds with the correct HTTP status code' do
        expect(response.status).to be(200)
      end

      it 'renders a JSON document' do
        expected = {
          'done' => 0,
          'total' => 2,
          'past_participle' => 'added'
        }
        @parsed_response.should == expected
      end
    end

    context 'when the batch does not exist' do
      let(:batch_id) { 999999 }

      it '404s (as a 500 often offends)' do
        expect(response.status).to be(404)
      end
    end
  end
end
