require "rails_helper"

describe FilterHelper do
  describe "#hidden_filter_fields_except" do
    let(:filter) do
      double("filter").tap do |filter|
        View::Mappings::Filter.fields.each do |field|
          allow(filter).to receive(field).and_return("field value")
        end
      end
    end

    subject { helper.hidden_filter_fields_except(filter, :path_contains) }

    it { is_expected.to be_an(ActiveSupport::SafeBuffer) }

    it "includes links to all the fields except path_contains" do
      expect(subject).to     have_selector('input#type[name="type"][type="hidden"]', visible: false)
      expect(subject).not_to have_selector('input#path_contains[name="path_contains"][type="hidden"]')
    end

    it "excludes fields that are blank" do
      allow(filter).to receive(:new_url_contains).and_return("")
      expect(subject).not_to have_selector('input#new_url_contains[name="new_url_contains"][type="hidden"]')
    end
  end
end
