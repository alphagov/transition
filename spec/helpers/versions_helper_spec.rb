require "rails_helper"

describe VersionsHelper do
  describe "#friendly_field_name" do
    specify { expect(helper.friendly_field_name("type")).to eq("Type") }

    specify { expect(helper.friendly_field_name("archive_url")).to eq("Custom Archive URL") }

    specify { expect(helper.friendly_field_name("miscellaneous")).to eq("Miscellaneous") }
  end

  describe "#friendly_changeset_title_for_type" do
    specify { expect(helper.friendly_changeset_title_for_type("archive")).to eq("Switched mapping to an Archive") }

    specify { expect(helper.friendly_changeset_title_for_type("redirect")).to eq("Switched mapping to a Redirect") }

    specify { expect(helper.friendly_changeset_title_for_type("foo")).to eq("Switched mapping type") }
  end

  describe "#friendly_changeset_title" do
    specify { expect(helper.friendly_changeset_title("id" => 1)).to eq("Mapping created") }

    specify { expect(helper.friendly_changeset_title("archive_url" => 1)).to eq("Custom Archive URL updated") }

    specify { expect(helper.friendly_changeset_title("miscellaneous" => 1)).to eq("Miscellaneous updated") }

    specify { expect(helper.friendly_changeset_title("archive_url" => 1, "miscellaneous" => 1)).to eq("Multiple properties updated") }

    specify { expect(helper.friendly_changeset_title("type" => %w[redirect archive])).to eq("Switched mapping to an Archive") }
  end

  describe "#friendly_changeset_old_to_new" do
    specify { expect(helper.friendly_changeset_old_to_new("misc", %w[old new])).to eq("old → new") }

    specify { expect(helper.friendly_changeset_old_to_new("misc", ["", "new"])).to eq("<blank> → new") }

    specify { expect(helper.friendly_changeset_old_to_new("type", %w[archive redirect])).to eq("Archive → Redirect") }

    specify { expect(helper.friendly_changeset_old_to_new("type", ["", "redirect"])).to eq("<blank> → Redirect") }
  end
end
