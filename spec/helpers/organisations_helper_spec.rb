require "rails_helper"

describe OrganisationsHelper do
  describe "#date_or_not_yet" do
    specify { expect(helper.date_or_not_yet(nil)).to eq("No date set") }
    specify { expect(helper.date_or_not_yet(Date.new(2014))).to eq("1 January 2014") }
  end

  describe "#add_indefinite_article" do
    specify { expect(helper.add_indefinite_article("non-departmental body")).to eq("a non-departmental body") }
    specify { expect(helper.add_indefinite_article("advisory non-departmental body")).to eq("an advisory non-departmental body") }
  end

  describe "#relationship_display_name" do
    let(:executive_body) { create :organisation }
    let(:other)          { create :organisation, whitehall_type: "Other" }

    specify { expect(helper.relationship_display_name(executive_body)).to eq("is an executive non-departmental public body of") }
    specify { expect(helper.relationship_display_name(other)).to eq("works with") }
  end

  describe "#links_to_all_parents" do
    let!(:org) { create :organisation }

    subject(:all_links) { helper.links_to_all_parents(org) }

    context "no parents" do
      it { is_expected.to eql("") }
    end

    context "one parent" do
      let!(:parent_1) { create :organisation }
      before do
        org.parent_organisations << parent_1
      end

      it "should be a link to the only parent" do
        expected = link_to parent_1.title, organisation_path(parent_1)
        expect(all_links).to eql(expected)
      end
    end

    context "two parents" do
      let!(:parent_1) { create :organisation }
      let!(:parent_2) { create :organisation }
      before do
        org.parent_organisations << [parent_1, parent_2]
      end

      it "should be two links to the parents, separated by and" do
        expected = link_to parent_1.title, organisation_path(parent_1)
        expected += " and "
        expected += link_to parent_2.title, organisation_path(parent_2)
        expect(all_links).to eql(expected)
      end
    end

    context "three parents" do
      let!(:parent_1) { create :organisation }
      let!(:parent_2) { create :organisation }
      let!(:parent_3) { create :organisation }
      before do
        org.parent_organisations << [parent_1, parent_2, parent_3]
      end

      it "should be three links to all the parents, separated by , and" do
        expected = link_to parent_1.title, organisation_path(parent_1)
        expected += ", "
        expected += link_to parent_2.title, organisation_path(parent_2)
        expected += " and "
        expected += link_to parent_3.title, organisation_path(parent_3)
        expect(all_links).to eql(expected)
      end
    end
  end
end
