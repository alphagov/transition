require 'spec_helper'
require 'transition/import/dns_details'

describe Transition::Import::DnsDetails do
  describe '#from_nameserver!' do
    let(:transitioned)        { create :host, hostname: 'www.direct.gov.uk' }
    let(:wont_transition)     { create :host, hostname: 'a.root-servers.net' }

    let(:hosts) { [transitioned, wont_transition] }

    before { Transition::Import::DnsDetails.from_nameserver!(hosts) }

    describe 'The transitioned host' do
      subject { transitioned }

      its(:cname) { should =~ /gov.uk$/ }
      its(:ttl)   { should be > 1 && be < 999999 }
    end

    describe 'The host that is not transitioning' do
      subject { wont_transition }

      its(:cname) { should be_nil }
      its(:ttl)   { should be_nil }
    end
  end
end
