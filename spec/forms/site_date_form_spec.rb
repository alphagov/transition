require "rails_helper"

describe SiteDateForm do
  describe "validations" do
    describe "#launch_date" do
      context "when the year part attribute is missing" do
        it "is invalid" do
          site_form = SiteDateForm.new("launch_date(3i)": "14", "launch_date(2i)": "10", "launch_date(1i)": "")

          expect(site_form.valid?).to be false
          expect(site_form.errors[:launch_date]).to include("The date of transition must include a year")
        end
      end

      context "when the month part attribute is missing" do
        it "is invalid" do
          site_form = SiteDateForm.new("launch_date(3i)": "14", "launch_date(2i)": "", "launch_date(1i)": "1066")

          expect(site_form.valid?).to be false
          expect(site_form.errors[:launch_date]).to include("The date of transition must include a month")
        end
      end

      context "when the day part attribute is missing" do
        it "is invalid" do
          site_form = SiteDateForm.new("launch_date(3i)": "", "launch_date(2i)": "10", "launch_date(1i)": "1066")

          expect(site_form.valid?).to be false
          expect(site_form.errors[:launch_date]).to include("The date of transition must include a day")
        end
      end
    end
  end

  describe "#save" do
    context "when invalid" do
      it "returns false" do
        site_form = SiteDateForm.new

        expect(site_form.save).to be false
      end
    end

    context "when valid" do
      it "updates the site and returns true" do
        site = create(:site, abbr: "cabinet-office")
        site_form = SiteDateForm.new(
          site:,
          "launch_date(3i)": "14",
          "launch_date(2i)": "10",
          "launch_date(1i)": "1066",
        )

        result = site_form.save

        expect(site.launch_date).to eq Date.new(1066, 10, 14)
        expect(result).to be true
      end
    end
  end
end
