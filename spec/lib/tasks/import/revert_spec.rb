require "rails_helper"

RSpec.describe "rake import:revert:hosts", type: :task do
  context "with host names" do
    it "deletes the host records" do
      site = create(:site)
      alias_1 = create(:host, site:)
      alias_2 = create(:host, site:)

      Rake::Task["import:revert:hosts"].invoke("#{alias_1.hostname},#{alias_2.hostname}")

      expect(Host.all.to_a).to eq([site.default_host])
    end
  end
end
