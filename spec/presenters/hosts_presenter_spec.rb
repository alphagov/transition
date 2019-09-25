require "rails_helper"

describe "HostsPresenter" do
  let!(:site)   { create :site }
  let!(:host_b) { create :host, site: site }
  let!(:host_c) { create :host, site: site }

  describe "#as_hash" do
    subject(:presented_hosts) { HostsPresenter.new(Host.includes(:site)).as_hash }

    describe "[:results]" do
      subject { super()[:results] }
      it { is_expected.not_to be_empty }
    end

    describe "[:total]" do
      subject { super()[:total] }
      it { is_expected.to be(3) }
    end

    describe "[:_response_info]" do
      subject { super()[:_response_info] }
      it { is_expected.not_to be_empty }
    end

    describe "#as_hash results" do
      subject(:results) { HostsPresenter.new(Host.includes(:site)).as_hash[:results] }

      it "contains the number of hosts" do
        expect(results.count).to be(3)
      end
    end
  end
end
