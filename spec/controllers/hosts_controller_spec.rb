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

    it 'provides the hostname and managed_by_transition for a host' do
      first_host = @parsed_response['results'].first
      expect(first_host).to have_key('hostname')
      expect(first_host).to have_key('managed_by_transition')
    end

    it 'contains twice the number of hosts (to include aka hostnames)' do
      expect(@parsed_response['results'].count).to be(6)
    end

    it 'contains the actual and aka hostnames for each stored host' do
      results = @parsed_response['results']
      hostnames = results[0..1].map { |h| h['hostname'] }
      expected_hostnames =
        [
          site.default_host.hostname,
          site.default_host.aka_hostname,
        ]
      expect(hostnames).to eql(expected_hostnames)
    end
  end
end
