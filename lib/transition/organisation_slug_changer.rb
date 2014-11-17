module Transition
  class OrganisationSlugChanger
    def initialize(old_slug, new_slug, options = {})
      @old_slug = old_slug
      @new_slug = new_slug
      @logger = options[:logger] || Logger.new(nil)
    end

    def call
      if organisation.present?
        logger.info "Updating slug for organisation '#{old_slug}'"
        change_organisation_slug
        true
      else
        logger.error "No organisation found with whitehall_slug '#{old_slug}'"
        false
      end
    end

    def change_organisation_slug
      Organisation.transaction do
        update_organisation_slug
        update_users
      end
    end

  private

    attr_reader(
      :old_slug,
      :new_slug,
      :logger,
    )

    def organisation
      @organisation ||= Organisation.find_by_whitehall_slug(old_slug)
    end

    def update_organisation_slug
      organisation.update_attributes!(whitehall_slug: new_slug)
      logger.info "Changed whitehall_slug of Organisation '#{organisation.title}': '#{old_slug}' => '#{new_slug}'"
    end

    def update_users
      User.where(organisation_slug: old_slug).each do |user|
        user.update_attributes!(organisation_slug: new_slug)
      end
    end
  end
end
