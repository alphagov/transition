require 'spec_helper'
require 'transition/import/dns_details'

describe Transition::Import::DnsDetails do
  describe '#from_nameserver!' do
    let(:a_host) { create :host, hostname: 'www.direct.gov.uk' }

    describe 'a host that has a CNAME' do
      before do
        cname_record = double(name: 'redirector-cdn.production.govuk.service.gov.uk', ttl: 100)
        Resolv::DNS.any_instance.stub(:getresource).and_return(cname_record)
        Transition::Import::DnsDetails.from_nameserver!([a_host])
      end

      subject { a_host }

      its(:cname) { should =~ /gov.uk$/ }
      its(:ttl)   { should be_between(1, 999999) }
    end

    describe 'a host that does not have CNAME' do
      before do
        Resolv::DNS.any_instance.stub(:getresource).and_raise(Resolv::ResolvError)
        Transition::Import::DnsDetails.from_nameserver!([a_host])
      end

      subject { a_host }

      its(:cname) { should be_nil }
      its(:ttl)   { should be_nil }
    end
  end
end
