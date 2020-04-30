require "transition/import/whitehall_orgs"
require "ostruct"

module Transition
  module Import
    class Organisations
      def initialize(whitehall_orgs)
        @whitehall_orgs = whitehall_orgs
      end

      def whitehall_orgs
        @whitehall_orgs ||= WhitehallOrgs.new
      end

      def css_furl_fudge
        @css_furl_fudge ||= YAML.safe_load(File.read("db/seeds/css-furl-fudge.yml"), [Symbol])
      end

      def create(whitehall_org)
        Organisation.where(content_id: whitehall_org["details"]["content_id"]).first_or_initialize.tap do |target|
          target.whitehall_slug = whitehall_org["details"]["slug"]

          target.whitehall_type = whitehall_org["format"]
          target.title          = whitehall_org["title"]
          target.abbreviation   = whitehall_org["details"]["abbreviation"]
          if whitehall_org["web_url"].present?
            target.homepage =
              "https://www.gov.uk#{Addressable::URI.parse(whitehall_org['web_url']).path}"
          end

          fudge_for_org = css_furl_fudge[whitehall_org["details"]["slug"]]
          if fudge_for_org.present?
            target.css  = fudge_for_org[:css]
            target.furl = fudge_for_org[:furl]
          end

          # create org relationships through the parent end
          # of the association as they arise
          target.parent_organisations = whitehall_org["parent_organisations"].map do |parent|
            create(whitehall_orgs.by_id[parent["id"]])
          end

          target.save!
        end
      end

      def import!
        whitehall_orgs.organisations.each do |whitehall_org|
          create(whitehall_org)
        end
      end

      def self.from_whitehall!(whitehall_orgs = WhitehallOrgs.new)
        Organisation.transaction do
          Organisations.new(whitehall_orgs).import!
        rescue PG::InFailedSqlTransaction => e
          e.transaction.rollback
        end
      end
    end
  end
end
