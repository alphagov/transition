require 'spec_helper'

describe HostsController do
  describe '#index' do

    let(:site)   { create :site_with_default_host }
    let(:host_b) { create :host }
    let(:host_c) { create :host }

    before do
      site.hosts << [host_b, host_c]
    end

    it 'does not require authentication' do
      get :index, {:format => :json}
      expect(response.status).to be(200)
    end

    it 'lists all hosts' do
      get :index, {:format => :json}
      parsed_response = JSON.parse(response.body)
      expect(parsed_response.count).to be(3)
    end

    it 'provides the hostname and managed_by_transition for a host' do
      get :index, {:format => :json}
      first_host = JSON.parse(response.body).first
      expect(first_host).to have_key("hostname")
      expect(first_host).to have_key("managed_by_transition")
    end
  end
end
