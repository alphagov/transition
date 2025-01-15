class AddAlternativeArchiveTextToSites < ActiveRecord::Migration[8.0]
  def change
    add_column :sites, :alternative_archive_text, :text
  end
end
