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

    it 'provides the hostname and managed_by_transition for a host' do
      get :index, {:format => :json}
      first_host = JSON.parse(response.body).first
      expect(first_host).to have_key('hostname')
      expect(first_host).to have_key('managed_by_transition')
    end

    it 'contains twice the number of hosts (to include aka hostnames)' do
      get :index, {:format => :json}
      parsed_response = JSON.parse(response.body)
      expect(parsed_response.count).to be(6)
    end

    it 'contains the actual and aka hostnames for each stored host' do
      get :index, {:format => :json}
      parsed_response = JSON.parse(response.body)
      hostnames = parsed_response[0..1].map { |h| h['hostname'] }
      expected_hostnames =
        [
          site.default_host.hostname,
          site.default_host.aka_hostname,
        ]
      expect(hostnames).to eql(expected_hostnames)
    end
  end
end
