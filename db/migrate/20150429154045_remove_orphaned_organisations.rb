class RemoveOrphanedOrganisations < ActiveRecord::Migration
  class Site < ApplicationRecord
    belongs_to :organisation
  end

  class Organisation < ApplicationRecord
    has_many :sites
  end

  def up
    # This migration is written with the assumption that organisation
    # content_ids have been populated. Any without a content_id are either
    # duplicates or have been deleted from Whitehall.
    Organisation.where("content_id is NULL").each do |organisation|
      if organisation.sites.any?
        raise "Can't delete the orphaned organisation with slug: #{organisation.slug} as it has #{organisation.sites.count} sites. You need to get the latest site data from transition-config."
      else
        organisation.delete
      end
    end

    change_column_null :organisations, :content_id, false
    add_index :organisations, :content_id, unique: true
  end

  def down
    change_column_null :organisations, :content_id, true
  end
end
