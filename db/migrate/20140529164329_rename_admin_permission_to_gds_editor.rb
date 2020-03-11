class RenameAdminPermissionToGdsEditor < ActiveRecord::Migration
  class User < ApplicationRecord
    serialize :permissions, Array
  end

  def up
    User.where("permissions like '%admin%'").each do |user|
      user.permissions = user.permissions.map { |string| string == "admin" ? "GDS Editor" : string }
      user.save
    end
  end

  def down
    User.where("permissions like '%GDS Editor%'").each do |user|
      user.permissions = user.permissions.map { |string| string == "GDS Editor" ? "admin" : string }
      user.save
    end
  end
end
