require 'transition/import/whitehall_orgs'

module Transition
  module Import
    class Organisations
      def whitehall_orgs
        @whitehall_orgs ||= WhitehallOrgs.new
      end

      def create(whitehall_org)
        Organisation.where(whitehall_slug: whitehall_org.details.slug).first_or_initialize.tap do |target|
          target.whitehall_slug = whitehall_org.details.slug

          target.title          = whitehall_org.title
          target.abbreviation   = whitehall_org.details.abbreviation
          target.whitehall_type = whitehall_org.format

          # Redirector TODOs
          target.redirector_abbr = whitehall_org.details.slug # temporary, as unique constraint
                                                              # means this isn't as independent
                                                              # from redirector as we'd like.
          # target.launch_date     = WAS organisation.redirection_date

          # create org relationships through the parent end
          # of the association as they arise
          target.parent_organisations = whitehall_org.parent_organisations.map do |parent|
            create(whitehall_orgs.by_id[parent.id])
          end

          target.save!
        end
      end

      def import!
        whitehall_orgs.each do |whitehall_org|
          create(whitehall_org)
        end
      end

      def self.from_whitehall!
        Organisation.transaction do
          Organisations.new.import!
        end
      end
    end
  end
end
