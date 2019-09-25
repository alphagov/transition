require "rails_helper"

describe OrganisationalRelationship do
  describe "relationships" do
    it { is_expected.to belong_to(:parent_organisation).class_name("Organisation") }
    it { is_expected.to belong_to(:child_organisation).class_name("Organisation") }
  end

  describe "validations" do
    let!(:confused_org) { create(:organisation) }

    it "should prevent an organisation from being its own parent" do
      expect { confused_org.parent_organisations << confused_org }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
