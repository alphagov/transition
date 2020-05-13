require "rails_helper"

module View
  module Mappings
    describe Filter do
      let(:site) { build :site }

      subject(:filter) { Filter.new(site, params) }

      context "no filter params are passed" do
        let(:params) { {} }
        it { is_expected.not_to be_active }
      end

      context "an incompatible params archive filter" do
        let(:params) do
          {
            type: "archive",
            new_url_contains: "something",
          }
        end

        describe "#type" do
          subject { super().type }
          it { is_expected.to be_nil }
        end

        it { is_expected.to be_incompatible }
        it { is_expected.to be_active }
      end

      context "an incompatible params unresolved filter" do
        let(:params) do
          {
            type: "unresolved",
            new_url_contains: "something",
          }
        end

        describe "#type" do
          subject { super().type }
          it { is_expected.to be_nil }
        end
        it { is_expected.to be_incompatible }
        it { is_expected.to be_active }
      end

      context "unrecognised types don't count" do
        let(:params) { { type: "banana-cake" } }

        describe "#type" do
          subject { super().type }
          it { is_expected.to be_nil }
        end
        it { is_expected.not_to be_active }
      end

      context "when just sorting" do
        let(:params) { { sort: "by_hits" } }
        it { is_expected.to be_active }
      end

      describe "#query" do
        before { allow(filter).to receive(:params).and_return(params) }

        describe "altering tags" do
          context "when there are no tags" do
            let(:params) { { tagged_with: "" } }

            describe "#tags" do
              subject { super().tags }
              it { is_expected.to be_empty }
            end
          end

          context "when there are tags present" do
            let(:params) { { tagged: "one,two" } }

            describe "#tags" do
              subject { super().tags }
              it { is_expected.to eq(%w[one two]) }
            end
          end

          describe "adding and removing parts of the query string" do
            describe "#with_tag" do
              subject { filter.query.with_tag("tag") }

              context "no existing parameters" do
                let(:params) { {} }
                it { is_expected.to eql(tagged: "tag") }
              end

              context "with a page parameter" do
                let(:params) { { page: "2" } }
                it { is_expected.to eql(tagged: "tag") }
              end

              context "with existing tags" do
                let(:params) { { tagged: "a,b" } }
                it { is_expected.to eql(tagged: "a,b,tag") }
              end

              context "with tag already present" do
                let(:params) { { tagged: "a,tag" } }
                it { is_expected.to eql(tagged: "a,tag") }
              end
            end

            describe "#without_tag" do
              subject { filter.query.without_tag("tag") }

              context "without any parameters" do
                let(:params) { {} }
                it { is_expected.to eql({}) }
              end

              context "with a page parameter" do
                let(:params) { { page: "2" } }
                it { is_expected.to eql({}) }
              end

              context "with tag present" do
                let(:params) { { tagged: "a,tag" } }
                it { is_expected.to eql(tagged: "a") }
              end

              context "with only tag" do
                let(:params) { { tagged: "tag" } }
                it { is_expected.to eql({}) }
              end
            end
          end
        end

        describe "#with_type" do
          subject { filter.query.with_type("redirect") }

          context "without any parameters" do
            let(:params) { {} }
            it { is_expected.to eql(type: "redirect") }
          end

          context "with a page parameter" do
            let(:params) { { page: "2" } }
            it { is_expected.to eql(type: "redirect") }
          end

          context "with existing other parameters" do
            let(:params) { { tagged: "a,b" } }
            it { is_expected.to eql(tagged: "a,b", type: "redirect") }
          end

          context "with type already present" do
            let(:params) { { type: "archive" } }
            it { is_expected.to eql(type: "redirect") }
          end
        end

        describe "#without_type" do
          subject { filter.query.without_type }

          context "without any parameters" do
            let(:params) { {} }
            it { is_expected.to eql({}) }
          end

          context "with a page and type parameter" do
            let(:params) { { page: "2", type: "redirect" } }
            it { is_expected.to eql({}) }
          end

          context "with existing other parameters" do
            let(:params) { { tagged: "a,b", type: "redirect" } }
            it { is_expected.to eql(tagged: "a,b") }
          end
        end
      end

      context "params are fine and we'd like to filter and sort by everything" do
        let(:site) { create :site }
        let!(:mapping_where_everything_matches) do
          create :mapping,
                 type: "redirect",
                 new_url: "http://something.gov.uk/",
                 path: "/CanonicalIZED?q=1",
                 tag_list: %w[fee fi fo],
                 site: site
        end
        let!(:control_mapping) do
          create :mapping,
                 type: "archive",
                 path: "/somewhere_else",
                 site: site
        end

        let(:params) do
          {
            type: "redirect",
            new_url_contains: "something",
            path_contains: "CanonicalIZED?q=1",
            tagged: "fee,fi,fo",
            sort: "by_hits",
          }
        end

        it { is_expected.not_to be_incompatible }
        it { is_expected.to     be_active }

        describe "#type" do
          subject { super().type }
          it { is_expected.to eq("redirect") }
        end

        describe "#new_url_contains" do
          subject { super().new_url_contains }
          it { is_expected.to eq("something") }
        end

        describe "#path_contains" do
          subject { super().path_contains }
          it { is_expected.to eq("canonicalized") }
        end

        describe "#tagged" do
          subject { super().tagged }
          it { is_expected.to eq("fee,fi,fo") }
        end

        describe "#mappings" do
          subject { super().mappings }
          it { is_expected.to match_array([mapping_where_everything_matches]) }
        end

        describe "#sort_by_hits?" do
          subject { super().sort_by_hits? }
          it { is_expected.to be_truthy }
        end

        it "has been sorted by hits (even though there aren't any)" do
          expect(filter.mappings.first.hit_count).to eql(0)
        end
      end
    end
  end
end
