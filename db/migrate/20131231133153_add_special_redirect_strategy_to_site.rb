class AddSpecialRedirectStrategyToSite < ActiveRecord::Migration
  def change
    add_column :sites, :special_redirect_strategy, :string
  end
end
