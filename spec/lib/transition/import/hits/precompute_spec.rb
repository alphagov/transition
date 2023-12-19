require "rails_helper"
require "transition/import/hits/precompute"

describe Transition::Import::Hits::Precompute do
  let(:new_precompute_value) { false }

  subject(:precompute_setter) do
    Transition::Import::Hits::Precompute.new(ids, new_precompute_value)
  end

  before do
    # We only care about certain console messages. Don't
    # let rspec-mocks bully us about the others.
    null_console = double("console").as_null_object
    # TODO: refactor to provide a setter or initialize argument to allow
    # this to be provided via a public api instead of forcing it like this
    precompute_setter.instance_variable_set("@console", null_console)
  end

  describe "#update!" do
    context "the sites we are updating do not exist" do
      let(:ids) { [123, 456, "", ""] }

      it "raises an error for the record it could not find" do
        expect { precompute_setter.update! }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "we are updating two sites, one already set" do
      let(:site_1) { create(:site, precompute_all_hits_view: false) }
      let(:site_2) { create(:site, precompute_all_hits_view: false) }
      let(:site_3) { create(:site, precompute_all_hits_view: true) }
      let(:ids) { [site_2.id, site_3.id] }
      let(:new_precompute_value) { true }

      it "updates one and skips the others" do
        expect(precompute_setter.console).to receive(:puts).with(
          "WARN: skipping site with ID '#{site_3.id}' - already set to true",
        )
        expect(precompute_setter).to receive(:inform_about_refresh)
        expect(precompute_setter.update!).to eq(1)
      end
    end

    context "we are updating a site not to precompute" do
      let(:site) { create(:site, precompute_all_hits_view: true) }
      let(:ids) { [site.id] }
      let(:new_precompute_value) { false }

      it "updates one, and does not remind us to refresh" do
        expect(precompute_setter).not_to receive(:inform_about_refresh)
        expect(precompute_setter.update!).to eq(1)
      end
    end
  end
end
