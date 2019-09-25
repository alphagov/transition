require "rails_helper"
require "transition/import/materialized_views/hits"

describe Transition::Import::MaterializedViews::Hits do
  describe ".refresh!", testing_before_all: true do
    before :all do
      @sites = [
        create(:site, abbr: "cabinet_office"),
        create(:site, abbr: "hmrc",         precompute_all_hits_view: true),
        create(:site, abbr: "ofsted",       precompute_all_hits_view: true),
      ]
      @sites.each do |site|
        ActiveRecord::Base.connection.execute(
          <<-POSTGRESQL,
            DROP MATERIALIZED VIEW IF EXISTS #{site.abbr}_all_hits
          POSTGRESQL
        )
      end
      Transition::Import::MaterializedViews::Hits.replace!
    end

    it "does not create views for small sites" do
      expect(Postgres::MaterializedView).not_to exist("cabinet_office_all_hits")
    end
    it "creates a view for the large site hmrc" do
      expect(Postgres::MaterializedView).to exist("hmrc_all_hits")
    end
    it "creates a view for the large site ofsted" do
      expect(Postgres::MaterializedView).to exist("ofsted_all_hits")
    end

    context "a second refresh with updated hits now views already exist" do
      before :all do
        ofsted = @sites.find { |s| s.abbr == "ofsted" }
        ofsted.default_host.hits << create(:hit, host: ofsted.default_host)

        Transition::Import::MaterializedViews::Hits.replace!
      end

      it "refreshes the view" do
        expect(Hit.select("*").from("ofsted_all_hits").size).to eq(1)
      end
    end
  end
end
