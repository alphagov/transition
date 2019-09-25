require "rails_helper"

describe WhitelistedHost do
  describe "validations" do
    subject { create(:whitelisted_host) }
    it { is_expected.to validate_presence_of(:hostname) }
    it { is_expected.to validate_uniqueness_of(:hostname).with_message("is already in the list").case_insensitive }

    describe "hostname" do
      context "is invalid" do
        subject(:whitelisted_host) { build(:whitelisted_host, hostname: "a.gov.uk/") }

        describe "#valid?" do
          subject { super().valid? }
          it { is_expected.to be_falsey }
        end
        it "should have an error for invalid hostname" do
          expect(whitelisted_host.errors_on(:hostname)).to include("is an invalid hostname")
        end
      end

      context "is automatically allowed anyway" do
        subject(:whitelisted_host) { build(:whitelisted_host, hostname: "a.gov.uk") }

        describe "#valid?" do
          subject { super().valid? }
          it { is_expected.to be_falsey }
        end
        it "should have an error" do
          expect(whitelisted_host.errors_on(:hostname)).to include("cannot end in .gov.uk, .mod.uk or .nhs.uk - these are automatically whitelisted")
        end
      end

      context "is valid" do
        subject(:whitelisted_host) { build(:whitelisted_host, hostname: "B.com ") }

        describe "#valid?" do
          subject { super().valid? }
          it { is_expected.to be_truthy }
        end
        it "should strip whitespace and downcase the hostname" do
          # This processing is done in before_validation callbacks, so we need
          # to trigger validation first:
          whitelisted_host.valid?
          expect(whitelisted_host.hostname).to eq("b.com")
        end
      end
    end
  end

  it "has a paper trail" do
    is_expected.to be_versioned
  end
end
