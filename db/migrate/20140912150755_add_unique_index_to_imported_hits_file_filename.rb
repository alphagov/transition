class AddUniqueIndexToImportedHitsFileFilename < ActiveRecord::Migration
  def change
    add_index :imported_hits_files, :filename, unique: true
  end
end
