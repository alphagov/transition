require "spec_helper"

describe MappingsBatchJob do
  describe "perform" do
    describe "recording history", versioning: true do
      let(:user) { create(:user, name: "Bob") }
      let(:mappings_batch) { create(:bulk_add_batch, user:) }

      before { MappingsBatchJob.new.perform(mappings_batch.id) }

      subject { Mapping.first.versions.last }

      describe "#whodunnit" do
        subject { super().whodunnit }
        it { is_expected.to eql("Bob") }
      end

      describe "#user_id" do
        subject { super().user_id }
        it { is_expected.to eql(user.id) }
      end
    end

    context "batch being deleted before processing" do
      it "should not raise an error" do
        expect { MappingsBatchJob.new.perform(1234) }.to_not raise_error
      end
    end
  end
end
