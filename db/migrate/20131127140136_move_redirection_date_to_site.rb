class MoveRedirectionDateToSite < ActiveRecord::Migration
  class Organisation < ActiveRecord::Base
  end

  class Site < ActiveRecord::Base
    belongs_to :organisation
  end

  def up
    add_column :sites, :launch_date, :date
    Site.all.each do |site|
      site.update_attribute(:launch_date, site.organisation.launch_date)
    end
    remove_column :organisations, :launch_date
  end

  def down
    add_column :organisations, :launch_date, :date
    Organisation.all.each do |organisation|
      organisation.update_attribute(:launch_date, organisation.sites.first.launch_date)
    end
    remove_column :sites, :launch_date
  end
end
