require 'spec_helper'

describe HostsController do
  describe '#index' do

    let(:site)   { create :site_with_default_host }
    let(:host_b) { create :host }
    let(:host_c) { create :host }

    before do
      site.hosts << [host_b, host_c]
      get :index
      @parsed_response = JSON.parse(response.body)
    end

    it 'does not require authentication' do
      expect(response.status).to be(200)
    end

    it 'contains results, total and response info' do
      %w(results total _response_info).each do |key|
        expect(@parsed_response).to have_key(key)
      end
    end
  end
end
