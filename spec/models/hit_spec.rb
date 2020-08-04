require "rails_helper"

describe Hit do
  describe "relationships" do
    it { is_expected.to belong_to(:host) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:host) }
    it { is_expected.to validate_presence_of(:path) }
    it { is_expected.to validate_presence_of(:count) }
    it { is_expected.to validate_numericality_of(:count).is_greater_than_or_equal_to(0) }
  end

  describe "attributes set before validation" do
    subject { create :hit, hit_on: Time.zone.local(2014, 12, 31, 23, 59, 59) }

    describe "#hit_on" do
      subject { super().hit_on }
      it { is_expected.to eql(Date.parse("2014-12-31")) }
    end
  end

  describe "#homepage?" do
    specify { expect(create(:hit, path: "/").homepage?).to be_truthy }
    specify { expect(create(:hit, path: "/?q=1").homepage?).to be_truthy }
    specify { expect(create(:hit, path: "/foo").homepage?).to be_falsey }
  end
end
