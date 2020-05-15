require "rails_helper"

describe BatchOutcomePresenter do
  let!(:site) { create(:site) }

  describe "#success_message" do
    let(:batch) do
      create(
        :bulk_add_batch,
        site: site,
        tag_list: "fee, fi, fo",
        type: "archive",
        update_existing: true,
        paths: ["/a", "/B", "/c?canonical=no", "/might-exist"],
      )
    end

    subject { BatchOutcomePresenter.new(batch).success_message }

    context "when updating at least one existing mapping" do
      let!(:existing_mapping) { create(:archived, site: site, path: "/might-exist") }

      before { batch.process }

      it { is_expected.to eql('3 mappings created and 1 mapping updated. All tagged with "fee, fi, fo".') }
    end

    context "when updating only existing mappings" do
      let!(:existing_mappings) do
        create(:archived, site: site, path: "/might-exist")
        create(:archived, site: site, path: "/a")
        create(:archived, site: site, path: "/b")
        create(:archived, site: site, path: "/c")
      end

      before { batch.process }

      context "when updating and tagging" do
        it { is_expected.to eql('4 mappings updated and tagged with "fee, fi, fo"') }
      end

      context "when not tagging" do
        before { batch.update_column(:tag_list, nil) }
        it { is_expected.to eql("4 mappings updated") }
      end
    end

    context "there are no pre-existing mappings" do
      before  { batch.process }

      context "when creating some mappings and updating none" do
        it { is_expected.to eql('4 mappings created and tagged with "fee, fi, fo"') }
      end

      context "when creating some mappings, updating none and tagging none" do
        before { batch.update_column(:tag_list, nil) }

        it { is_expected.to eql("4 mappings created") }
      end
    end
  end

  describe "#analytics_event_type" do
    subject { BatchOutcomePresenter.new(batch).analytics_event_type }

    context "bulk adding archives" do
      let(:batch) { build(:bulk_add_batch, type: "archive") }
      it { is_expected.to eql("bulk-add-archive-ignore-existing") }
    end

    context "bulk adding redirects" do
      let(:batch) { build(:bulk_add_batch, type: "redirect") }
      it { is_expected.to eql("bulk-add-redirect-ignore-existing") }
    end

    context "bulk adding archives with overwrite" do
      let(:batch) { build(:bulk_add_batch, type: "archive", update_existing: true) }
      it { is_expected.to eql("bulk-add-archive-overwrite-existing") }
    end

    context "bulk adding redirects with overwrite" do
      let(:batch) { build(:bulk_add_batch, type: "redirect", update_existing: true) }
      it { is_expected.to eql("bulk-add-redirect-overwrite-existing") }
    end
  end
end
