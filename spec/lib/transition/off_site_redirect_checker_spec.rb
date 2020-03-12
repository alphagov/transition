require "rails_helper"
require "transition/off_site_redirect_checker"

describe Transition::OffSiteRedirectChecker do
  describe "on_site?" do
    subject do
      Transition::OffSiteRedirectChecker.on_site?(location)
    end

    context "genuine path" do
      let(:location) { "/a/path" }
      it { is_expected.to eq(true) }
    end

    context "absolute URI" do
      let(:location) { "http://malicious.com" }
      it { is_expected.to eq(false) }
    end

    context "triple leading slash" do
      let(:location) { "///malicious.com" }
      it { is_expected.to eq(false) }
    end

    context "protocol-relative URL" do
      let(:location) { "//malicious.com" }
      it { is_expected.to eq(false) }
    end

    context "nil" do
      let(:location) { nil }
      it { is_expected.to eq(false) }
    end
  end
end
