class AddGoogleAnalyticsProfileIdToOrgs < ActiveRecord::Migration
  def change
    add_column :organisations, :ga_profile_id, :string, limit: 16
  end
end
