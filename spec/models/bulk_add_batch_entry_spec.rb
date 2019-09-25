require "rails_helper"

describe BulkAddBatchEntry do
  describe "disabled fields" do
    describe "should define getters for those fields and delegate them to the batch" do
      let(:mappings_batch) { build(:bulk_add_batch, new_url: "http://cheese", type: "redirect") }

      subject(:entry) { build(:bulk_add_batch_entry, mappings_batch: mappings_batch) }

      describe "#new_url" do
        subject { super().new_url }
        it { is_expected.to eql("http://cheese") }
      end

      describe "#type" do
        subject { super().type }
        it { is_expected.to eql("redirect") }
      end

      describe "#redirect?" do
        subject { super().redirect? }
        it { is_expected.to be_truthy }
      end
    end
  end
end
