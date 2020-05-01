require "rails_helper"
require "postgres/materialized_view"

describe Postgres::MaterializedView do
  def execute(sql)
    ActiveRecord::Base.connection.execute(sql)
  end

  before do
    # All tests start with an unmodified pre_existing_view
    execute(
      <<-POSTGRESQL,
        DROP MATERIALIZED VIEW IF EXISTS pre_existing_view;

        CREATE MATERIALIZED VIEW pre_existing_view
        AS
          SELECT 1 AS unmodified;
      POSTGRESQL
    )
  end

  describe ".exist?" do
    it "finds views that exist" do
      expect(Postgres::MaterializedView).to exist("pre_existing_view")
    end

    it "does not find views that don't exist" do
      expect(Postgres::MaterializedView).not_to exist("nonexistent_view")
    end
  end

  describe ".get_body" do
    it "gets the body" do
      expect(Postgres::MaterializedView.get_body(
               "pre_existing_view",
             )).to include("SELECT 1")
    end
  end

  describe ".create", truncate_everything: true do
    before { execute('DROP MATERIALIZED VIEW IF EXISTS "totally_new-view";') }
    after  { execute('DROP MATERIALIZED VIEW IF EXISTS "totally_new-view";') }

    context "no options given" do
      context "view already exists" do
        it "fails" do
          expect {
            Postgres::MaterializedView.create(
              "pre_existing_view",
              "SELECT 3 as doomed_attempt",
            )
          }.to raise_error(ActiveRecord::StatementInvalid, /PG::DuplicateTable/)
        end
      end

      context "view does not exist and view names need quoting" do
        it "creates new views" do
          Postgres::MaterializedView.create(
            "totally_new-view",
            "SELECT 1",
          )

          expect(Postgres::MaterializedView).to exist("totally_new-view")
        end
      end
    end

    context "replace requested" do
      it "replaces existing views" do
        Postgres::MaterializedView.create(
          "pre_existing_view",
          "SELECT 2 AS modified;",
          replace: true,
        )
        body = Postgres::MaterializedView.get_body("pre_existing_view")
        expect(body).to include("SELECT 2 AS modified")
      end
    end
  end

  describe ".drop" do
    it "drops views, yo" do
      Postgres::MaterializedView.drop("pre_existing_view")
      expect(Postgres::MaterializedView).not_to exist("pre_existing_view")
    end
  end

  describe ".refresh" do
    def view_row_count
      ActiveRecord::Base.connection.execute(
        "SELECT COUNT(*) FROM refreshable_orgs",
      ).first["count"].to_i
    end

    before do
      create :organisation

      execute(
        <<-POSTGRESQL,
          DROP MATERIALIZED VIEW IF EXISTS refreshable_orgs;

          CREATE MATERIALIZED VIEW refreshable_orgs
          AS
            SELECT * FROM organisations;
        POSTGRESQL
      )
    end

    it "refreshes a view" do
      create :organisation

      expect {
        Postgres::MaterializedView.refresh("refreshable_orgs")
      }.to change { view_row_count }.from(1).to(2)
    end
  end
end
