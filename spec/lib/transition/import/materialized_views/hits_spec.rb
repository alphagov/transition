require "rails_helper"
require "transition/import/materialized_views/hits"

describe Transition::Import::MaterializedViews::Hits do
  describe ".refresh!", testing_before_all: true do
    before :all do
      @sites = [
        create(:site),
        create(:site, precompute_all_hits_view: true),
        create(:site, precompute_all_hits_view: true),
      ]
      @sites.each do |site|
        ActiveRecord::Base.connection.execute(
          <<-POSTGRESQL,
            DROP MATERIALIZED VIEW IF EXISTS all_hits_#{site.id}
          POSTGRESQL
        )
      end
      Transition::Import::MaterializedViews::Hits.replace!
    end

    it "does not create views for small sites" do
      expect(Postgres::MaterializedView).not_to exist("all_hits_#{@sites[0].id}")
    end
    it "creates a view for the large site hmrc" do
      expect(Postgres::MaterializedView).to exist("all_hits_#{@sites[1].id}")
    end
    it "creates a view for the large site ofsted" do
      expect(Postgres::MaterializedView).to exist("all_hits_#{@sites[2].id}")
    end

    context "a second refresh with updated hits now views already exist" do
      before :all do
        ofsted = @sites[2]
        ofsted.default_host.hits << create(:hit, host: ofsted.default_host)

        Transition::Import::MaterializedViews::Hits.replace!
      end

      it "refreshes the view" do
        expect(Hit.select("*").from("all_hits_#{@sites[2].id}").size).to eq(1)
      end
    end
  end
end
