require "rails_helper"

describe SitesHelper do
  describe "#big_launch_days_number" do
    let(:site)      { double("site") }
    let(:halloween) { Date.new(2013, 10, 31) }

    around(:all) do |example|
      Timecop.freeze(halloween) { example.run }
    end

    before do
      allow(site).to receive(:launch_date).and_return(launch_date)
      allow(site).to receive(:transition_status).and_return(transition_status)
    end

    subject { helper.big_launch_days_number(site) }

    context "when launch date is not set" do
      let(:launch_date)       { nil }
      let(:transition_status) { :pre_transition }

      it { is_expected.to be_nil }
    end

    context "when launching 14 days in the future" do
      let(:launch_date)       { Date.new(2013, 11, 14) }
      let(:transition_status) { :pre_transition }
      it { is_expected.to include("14 days") }
      it { is_expected.to include("until transition") }
    end

    context "when launched 2 days ago" do
      let(:launch_date) { Date.new(2013, 10, 29) }
      let(:transition_status) { :live }
      it { is_expected.to include("2 days") }
      it { is_expected.to include("since transition") }
    end

    context "when launched yesterday" do
      let(:launch_date) { Date.new(2013, 10, 30) }
      let(:transition_status) { :live }
      it { is_expected.to include("1 day") }
      it { is_expected.to include("since transition") }
    end

    context "when launching later today" do
      let(:launch_date) { Date.new(2013, 10, 31) }
      let(:transition_status) { :pre_transition }
      it { is_expected.to include("0 days") }
      it { is_expected.to include("until transition") }
    end

    context "when launched earlier today" do
      let(:launch_date) { Date.new(2013, 10, 31) }
      let(:transition_status) { :live }
      it { is_expected.to include("0 days") }
      it { is_expected.to include("since transition") }
    end

    context "when launching tomorrow" do
      let(:launch_date) { Date.new(2013, 11, 1) }
      let(:transition_status) { :pre_transition }
      it { is_expected.to include("1 day") }
      it { is_expected.to include("until transition") }
    end

    context "the site was supposed to launch but its transition_status is pre-transition" do
      let(:launch_date)       { Date.new(2013, 10, 1) }
      let(:transition_status) { :pre_transition }
      it { is_expected.to include("30 days") }
      it { is_expected.to include("overdue") }
    end

    context "when the site's status is indeterminate" do
      context "when launching tomorrow" do
        let(:launch_date) { Date.new(2013, 11, 1) }
        let(:transition_status) { :indeterminate }
        it { is_expected.to include("1 day") }
        it { is_expected.to include("until transition") }
      end

      context "when launched yesterday" do
        let(:launch_date) { Date.new(2013, 10, 30) }
        let(:transition_status) { :indeterminate }
        it { is_expected.to include("1 day") }
        it { is_expected.to include("since transition") }
      end
    end
  end

  describe "calculating unresolved percentages" do
    let(:site) do
      double("site").tap do |site|
        allow(site).to receive_message_chain(:mappings, :unresolved, :count).and_return(unresolved_count)
        allow(site).to receive_message_chain(:mappings, :count).and_return(total_mappings)
      end
    end

    subject(:percentage) { helper.site_unresolved_mappings_percentage(site) }

    context "when there are no mappings" do
      let(:unresolved_count) { 0 }
      let(:total_mappings)   { 0 }

      it { is_expected.to eq("0%") }
    end

    context "when there are some mappings" do
      let(:unresolved_count) { 1 }
      let(:total_mappings)   { 2 }

      it { is_expected.to eq("50.0%") }
    end
  end
end
