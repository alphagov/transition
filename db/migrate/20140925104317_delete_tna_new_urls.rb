class DeleteTnaNewURLs < ActiveRecord::Migration
  class Mapping < ApplicationRecord
    self.inheritance_column = nil
  end

  def up
    Mapping.where("new_url LIKE '%webarchive.nationalarchives%'").each do |mapping|
      if mapping.type == "redirect"
        mapping.type = "archive"
        mapping.archive_url = mapping.new_url
      end
      mapping.new_url = nil
      mapping.save
    end
  end

  def down
    # Nothing here because we don't want to put back invalid data.
  end
end
