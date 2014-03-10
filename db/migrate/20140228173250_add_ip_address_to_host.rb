class AddIpAddressToHost < ActiveRecord::Migration
  def change
    add_column :hosts, :ip_address, :string
  end
end
