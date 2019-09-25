require "rails_helper"

describe HostPath do
  describe "path canonicalization" do
    let(:uncanonicalized_path) { "/A/b/c?significant=1&really-significant=2&insignificant=2" }
    let(:canonicalized_path)   { "/a/b/c?really-significant=2&significant=1" }
    let(:site)                 { create(:site, query_params: "significant:really-significant") }
    let(:host)                 { site.hosts.first }

    subject do
      create(:host_path, path: uncanonicalized_path, host: host)
    end

    describe "#path" do
      subject { super().path }
      it { is_expected.to eql(uncanonicalized_path) }
    end

    describe "#canonical_path" do
      subject { super().canonical_path }
      it { is_expected.to eql(canonicalized_path) }
    end
  end
end
