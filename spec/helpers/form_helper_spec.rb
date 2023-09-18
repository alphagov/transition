require "rails_helper"

class FakeModel
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :fake_attribute
  validates :fake_attribute, length: { maximum: 5 }
  validates :fake_attribute, format: { with: /[A-Z]+/ }
end

describe FormHelper do
  let(:fake_model) { FakeModel.new(fake_attribute:) }

  describe "#error_messages" do
    subject { helper.error_messages(fake_model) }

    before { fake_model.valid? }

    context "when a field has an error" do
      let(:fake_attribute) { "INVALID" }

      it "returns a hash of error messages and links" do
        expect(subject).to eq [{ href: "#fake_model_fake_attribute", text: "is too long (maximum is 5 characters)" }]
      end
    end

    context "when there are multiple errors messages for the same field" do
      let(:fake_attribute) { "invalid" }

      it "returns only the first error message" do
        expect(subject).to eq [{ href: "#fake_model_fake_attribute", text: "is too long (maximum is 5 characters)" }]
      end
    end
  end

  describe "#error_message" do
    let(:fake_attribute) { "INVALID" }

    before { fake_model.valid? }

    subject { helper.error_message(fake_model, :fake_attribute) }

    it "returns the first error associated with a field" do
      expect(subject).to eq "is too long (maximum is 5 characters)"
    end
  end

  describe "#field_id_attribute" do
    let(:fake_attribute) { "VALID" }

    subject { helper.field_id_attribute(fake_model, :fake_attribute) }

    it "returns the object name and field name in snake case" do
      expect(subject).to eq "fake_model_fake_attribute"
    end
  end

  describe "#object has errors" do
    before { fake_model.valid? }

    subject { helper.object_has_errors?(fake_model) }

    context "when object has no errors" do
      let(:fake_attribute) { "VALID" }

      it { expect(subject).to be false }
    end

    context "when object has errors" do
      let(:fake_attribute) { "INVALID" }

      it { expect(subject).to be true }
    end
  end
end
