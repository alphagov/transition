require "rails_helper"

describe HostsController do
  describe "#index" do
    let(:site) { create :site }

    before do
      get :index
      @parsed_response = JSON.parse(response.body)
    end

    it "does not require authentication" do
      expect(response.status).to be(200)
    end

    it "contains results, total and response info" do
      %w[results total _response_info].each do |key|
        expect(@parsed_response).to have_key(key)
      end
    end

    it "will not be cached" do
      expect(response.headers["Cache-Control"]).to eq("no-cache")
    end
  end
end
