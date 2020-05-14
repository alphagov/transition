require "rails_helper"
require "transition/import/dns_details"

describe Transition::Import::DnsDetails do
  describe "#from_nameserver!" do
    let(:a_host) { create :host, hostname: "www.direct.gov.uk" }

    describe "a host that has a CNAME" do
      before do
        cname_record = double(name: "redirector-cdn.production.govuk.service.gov.uk", ttl: 100)
        allow_any_instance_of(Resolv::DNS)
            .to receive(:getresource).with("www.direct.gov.uk", Resolv::DNS::Resource::IN::CNAME)
            .and_return(cname_record)

        Transition::Import::DnsDetails.from_nameserver!([a_host])
      end

      subject { a_host }

      describe "#cname" do
        subject { super().cname }
        it { is_expected.to match(/gov.uk$/) }
      end

      describe "#ip_address" do
        subject { super().ip_address }
        it { is_expected.to be_nil }
      end

      describe "#ttl" do
        subject { super().ttl }
        it { is_expected.to be_between(1, 999_999) }
      end
    end

    describe "a host that does not have a CNAME" do
      before do
        allow_any_instance_of(Resolv::DNS)
            .to receive(:getresource).with("www.direct.gov.uk", Resolv::DNS::Resource::IN::CNAME)
            .and_raise(Resolv::ResolvError)

        a_record = double(address: "1.1.1.1", ttl: 100)
        allow_any_instance_of(Resolv::DNS)
            .to receive(:getresource).with("www.direct.gov.uk", Resolv::DNS::Resource::IN::A)
            .and_return(a_record)

        Transition::Import::DnsDetails.from_nameserver!([a_host])
      end

      subject { a_host }

      describe "#cname" do
        subject { super().cname }
        it { is_expected.to be_nil }
      end

      describe "#ip_address" do
        subject { super().ip_address }
        it { is_expected.to eql("1.1.1.1") }
      end

      describe "#ttl" do
        subject { super().ttl }
        it { is_expected.to eql(100) }
      end
    end
  end
end
