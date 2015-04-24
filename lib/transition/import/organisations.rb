require 'transition/import/whitehall_orgs'
require 'ostruct'

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
        @css_furl_fudge ||= YAML.load(File.read('db/seeds/css-furl-fudge.yml'))
      end

      def create(whitehall_org)
        Organisation.where(whitehall_slug: whitehall_org.details.slug).first_or_initialize.tap do |target|
          target.whitehall_slug  = whitehall_org.details.slug
          target.content_id     = whitehall_org.details.content_id

          target.whitehall_type = whitehall_org.format
          target.title          = whitehall_org.title
          target.abbreviation   = whitehall_org.details.abbreviation
          target.homepage       =
            "https://www.gov.uk#{Addressable::URI.parse(whitehall_org.web_url).path}" if whitehall_org.web_url.present?

          if fudge_for_org = css_furl_fudge[whitehall_org.details.slug]
            target.css  = fudge_for_org[:css]
            target.furl = fudge_for_org[:furl]
          end

          # create org relationships through the parent end
          # of the association as they arise
          target.parent_organisations = whitehall_org.parent_organisations.map do |parent|
            create(whitehall_orgs.by_id[parent.id])
          end

          target.save!
        end
      end

      def import!
        whitehall_orgs.organisations.concat(Organisations.that_never_existed).each do |whitehall_org|
          create(whitehall_org)
        end
      end

      def self.from_whitehall!(whitehall_orgs = WhitehallOrgs.new)
        Organisation.transaction do
          begin
            Organisations.new(whitehall_orgs).import!
          rescue PG::InFailedSqlTransaction => e
            e.transaction.rollback
          end
        end
      end

      def Organisations.that_never_existed
        [
          OpenStruct.new({
                           title: 'Directgov',
                           parent_organisations: [],
                           details: OpenStruct.new({
                             slug: 'directgov',
                             abbreviation: nil
                           })
                         }),
          OpenStruct.new({
                           title: 'Business Link',
                           parent_organisations: [],
                           details: OpenStruct.new({
                             slug: 'business-link',
                             abbreviation: nil
                           })
                         })
        ]
      end
    end
  end
end
