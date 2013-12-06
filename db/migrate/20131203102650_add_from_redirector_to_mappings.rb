class AddFromRedirectorToMappings < ActiveRecord::Migration
  def change
    add_column :mappings, :from_redirector, :boolean, default: false
  end
end
