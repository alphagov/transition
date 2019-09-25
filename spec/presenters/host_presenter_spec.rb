require "rails_helper"

describe "HostPresenter" do
  describe "#as_hash" do
    let(:site) { create(:site) }
    let(:host) { site.default_host }

    subject { HostPresenter.new(host).as_hash }

    it { is_expected.to have_key(:hostname) }

    describe "[:hostname]" do
      subject { super()[:hostname] }
      it { is_expected.to eql(host.hostname) }
    end
  end
end
