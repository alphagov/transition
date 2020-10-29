require "rails_helper"
require "transition/import/daily_hit_totals"
require "postgres/materialized_view"

describe HitsController do
  let(:site) do
    create :site, precompute_all_hits_view: precompute_all_hits_view do |site|
      site.hosts << create(:host, hostname: "alias.gov.uk", site: site)
    end
  end

  let(:host)                     { site.default_host }
  let(:host_alias)               { site.hosts.last }
  let(:precompute_all_hits_view) { false }

  let!(:errors) do
    [
      create(:hit, host: host, hit_on: "2012-12-28", count: 1, http_status: "404"),
      create(:hit, host: host, hit_on: "2012-12-31", count: 1, http_status: "404"),
    ]
  end
  let!(:archives) do
    [
      create(:hit, host: host, hit_on: "2012-12-28", count: 2, http_status: "410"),
      create(:hit, host: host, hit_on: "2012-12-31", count: 2, http_status: "410"),
      create(:hit, host: host_alias, hit_on: "2012-12-31", count: 2, http_status: "410"),
    ]
  end

  around(:example) do |example|
    Timecop.freeze(Date.new(2013, 1, 1)) { example.run }
  end

  before do
    login_as_stub_user
    Transition::Import::DailyHitTotals.from_hits!
  end

  describe "#category" do
    before do
      get :category, params: { site_id: site, category: test_category_name }
    end

    subject(:category)      { assigns[:category] }
    let(:sum_of_hit_counts) { category.points.inject(0) { |sum, hit| sum + hit.count } }

    context "a single-status category, errors" do
      let(:test_category_name) { "errors" }

      it "has four points" do
        expect(category.points.size).to eq(4)
      end
      it "adds up to two total errors" do
        expect(sum_of_hit_counts).to eq(2)
      end
    end

    context "a multi-status category, archives" do
      let(:test_category_name) { "archives" }

      it "has four points" do
        expect(category.points.size).to eq(4)
      end
      it "adds up to six total archives" do
        expect(sum_of_hit_counts).to eq(6)
      end
      it "groups hits by path and status" do
        results = category.hits.map { |r| [r.http_status, r.path, r.count] }
        expect(results).to eq([
          ["410", "/article/123", 6],
        ])
        expect(category.hits.length).to eq(1)
      end
    end
  end

  describe "#index", truncate_everything: true do
    let(:category) { assigns[:category] }
    let(:paths)    { category.hits.map { |h| [h.http_status, h.path, h.count] } }

    before do
      expect(Site).to receive(:find_by!).and_return(site)
    end

    shared_examples "it has hits and points whether or not we used a view" do
      it "has paths once for each status ordered by descending count" do
        expect(paths).to eq([["410", "/article/123", 6],
                             ["404", "/article/123", 2]])
      end
      it "has four points" do
        expect(category.points.size).to eq(4)
      end
    end

    context "site is small; all hits view is not precomputed" do
      before do
        expect(site).not_to receive(:precomputed_all_hits)

        get :index, params: { site_id: site, period: "all-time" }
      end

      it_behaves_like "it has hits and points whether or not we used a view"
    end

    context "site is large; all hits view is precomputed" do
      let(:precompute_all_hits_view) { true }

      context "the view has been precomputed" do
        before do
          Transition::Import::MaterializedViews::Hits.replace!

          expect(site).to receive(:precomputed_all_hits).and_call_original

          get :index, params: { site_id: site, period: "all-time" }
        end

        it_behaves_like "it has hits and points whether or not we used a view"
      end

      context "the view is not yet there, so we fall back to calculation" do
        before do
          ActiveRecord::Base.connection.execute(
            %(DROP MATERIALIZED VIEW IF EXISTS "#{site.precomputed_view_name}"),
          )

          expect(site).not_to receive(:precomputed_all_hits)

          get :index, params: { site_id: site, period: "all-time" }
        end

        it_behaves_like "it has hits and points whether or not we used a view"
      end
    end
  end
end
