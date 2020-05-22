class MoveRedirectionDateToSite < ActiveRecord::Migration
  class Organisation < ApplicationRecord
  end

  class Site < ApplicationRecord
    belongs_to :organisation
  end

  def up
    add_column :sites, :launch_date, :date
    Site.all.each do |site|
      site.update(launch_date: site.organisation.launch_date)
    end
    remove_column :organisations, :launch_date
  end

  def down
    add_column :organisations, :launch_date, :date
    Organisation.all.each do |organisation|
      organisation.update(launch_date: organisation.sites.first.launch_date)
    end
    remove_column :sites, :launch_date
  end
end
