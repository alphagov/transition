require "rails_helper"

describe TagsHelper do
  describe "#most_used_tags_json" do
    let!(:site) { create(:site) }
    let!(:mappings) do
      [
        create(:mapping, tag_list: %w[tag1 tag2 tag3], site: site),
        create(:mapping, tag_list: %w[tag4 tag3 tag1], site: site),
        create(:mapping, tag_list: %w[tag5 tag4 tag1], site: site),
        create(:mapping, tag_list: %w[tag6 tag1 tag3], site: site),
      ]
    end

    subject(:tags_as_array) do
      helper.most_used_tags_json(site, options).gsub(/[\[\]"]/, "").split(",")
    end

    context "when no limit is set" do
      let(:options) { {} }
      it "returns all the tags for all the mappings" do
        expect(tags_as_array).to match_array(%w[tag1 tag2 tag3 tag4 tag5 tag6])
      end
    end

    context "when a limit of 3 is set" do
      let(:options) { { limit: 3 } }
      it "includes only the most-used tags" do
        expect(tags_as_array).to match_array(%w[tag1 tag3 tag4])
      end
    end
  end
end
