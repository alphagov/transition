class AddTitleAndFurlToSite < ActiveRecord::Migration
  def change
    add_column :sites, :homepage_title, :string
    add_column :sites, :homepage_furl, :string
  end
end
