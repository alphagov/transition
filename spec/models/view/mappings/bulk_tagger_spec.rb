require "rails_helper"

describe View::Mappings::BulkTagger do
  let!(:site) { create(:site) }
  let!(:mappings) do
    [
      create(:mapping, site: site, tag_list: "fee, fum, fox"),
      create(:mapping, site: site, tag_list: "fi, fum, fox"),
      create(:mapping, site: site, tag_list: "fo, fum, fox"),
    ]
  end
  let(:tag_list) { "fox, fiddle" }
  let(:bulk_tagger) do
    View::Mappings::BulkTagger.new(
      site,
      mapping_ids: mappings.map(&:id),
      tag_list: tag_list,
    )
  end

  it "has common tags from the mappings" do
    expect(bulk_tagger.common_tags).to match_array(%w[fum fox])
  end

  describe "#tag_list" do
    subject { bulk_tagger.tag_list }

    context "when the tag list is compact" do
      let(:tag_list) { "fox,fiddle" }
      it { is_expected.to eql("fox, fiddle") }
    end
    context "when the tag list is expanded" do
      let(:tag_list) { "fox,    fiddle" }
      it { is_expected.to eql("fox, fiddle") }
    end
    context "when the tag list is not supplied" do
      let(:tag_list) { nil }
      it { is_expected.to eql(bulk_tagger.common_tags.join(", ")) }
    end
  end

  describe "#update!" do
    before { bulk_tagger.update! }

    context 'we remove common tag "fum" and add "fiddle"' do
      let(:tag_list) { "fox, fiddle" }

      it "has seen no failures" do
        expect(bulk_tagger.failures).to be_empty
      end
      it "has updated mapping 1" do
        expect(mappings.first.reload.tag_list).to match_array(%w[fee fiddle fox])
      end
      it "has updated mapping 2" do
        expect(mappings.second.reload.tag_list).to match_array(%w[fi fiddle fox])
      end
      it "has updated mapping 3" do
        expect(mappings.third.reload.tag_list).to match_array(%w[fo fiddle fox])
      end
    end

    context "we remove all the common tags" do
      let(:tag_list) { "" }

      it "has seen no failures" do
        expect(bulk_tagger.failures).to be_empty
      end
      it "has updated mapping 1" do
        expect(mappings.first.reload.tag_list).to match_array(%w[fee])
      end
      it "has updated mapping 2" do
        expect(mappings.second.reload.tag_list).to match_array(%w[fi])
      end
      it "has updated mapping 3" do
        expect(mappings.third.reload.tag_list).to match_array(%w[fo])
      end
    end
  end
end
