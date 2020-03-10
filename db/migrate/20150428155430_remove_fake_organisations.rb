class RemoveFakeOrganisations < ActiveRecord::Migration
  class Site < ApplicationRecord
  end

  class Organisation < ApplicationRecord
    has_many :sites
  end

  def up
    Organisation.where(whitehall_slug: %w[directgov business-link]).each do |organisation|
      raise "Won't delete organisation with sites" if organisation.sites.any?

      organisation.delete
    end
  end

  def down
    # They would be recreated by importing the organisations under the old code.
  end
end
