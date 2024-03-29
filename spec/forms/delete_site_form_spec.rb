require "rails_helper"

describe DeleteSiteForm do
  let(:site) { create(:site) }

  describe "validations" do
    describe "#hostname_confirmation" do
      context "when the site hostname is incorrect" do
        it "is invalid" do
          site_form = DeleteSiteForm.new(id: site.id, hostname_confirmation: "incorrect.gov.uk")

          expect(site_form.valid?).to be false
          expect(site_form.errors[:hostname_confirmation]).to include("The confirmation did not match")
        end
      end
    end
  end

  describe "#save" do
    let(:mock_reverter_class) { class_double(Transition::Import::RevertEntirelyUnsafe::RevertSite).as_stubbed_const }
    let(:mock_reverter) { instance_double(Transition::Import::RevertEntirelyUnsafe::RevertSite) }

    before do
      allow(mock_reverter_class).to receive(:new).and_return(mock_reverter)
      allow(mock_reverter).to receive(:revert_all_data!)
    end

    context "when invalid" do
      it "returns false" do
        site_form = DeleteSiteForm.new(id: site.id, hostname_confirmation: "incorrect.gov.uk")

        expect(site_form.save).to be false
        expect(mock_reverter_class).to_not have_received(:new)
        expect(mock_reverter).to_not have_received(:revert_all_data!)
      end
    end

    context "when valid" do
      it "calls the reverter and returns true" do
        site_form = DeleteSiteForm.new(id: site.id, hostname_confirmation: site.default_host.hostname)

        result = site_form.save

        expect(result).to be true
        expect(mock_reverter_class).to have_received(:new).with(site)
        expect(mock_reverter).to have_received(:revert_all_data!)
      end
    end
  end
end
