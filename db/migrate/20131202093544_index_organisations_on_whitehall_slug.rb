class IndexOrganisationsOnWhitehallSlug < ActiveRecord::Migration
  def change
    add_index :organisations, :whitehall_slug, unique: true
  end
end
