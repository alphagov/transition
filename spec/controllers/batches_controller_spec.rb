require 'spec_helper'

describe BatchesController do
  describe 'GET #show' do
    let(:user) { create(:user) }
    let(:site) { create(:site) }
    let(:mappings_batch) { create(:mappings_batch, site: site, user: user) }

    before do
      login_as(user)
      get :show, site_id: site.abbr, id: mappings_batch.id
      @parsed_response = JSON.parse(response.body)
    end


    it 'responds with the correct HTTP status code' do
      expect(response.status).to be(200)
    end

    it 'renders a JSON document' do
      expected = {
        'done' => 0,
        'total' => 2
      }
      @parsed_response.should == expected
    end
  end
end
