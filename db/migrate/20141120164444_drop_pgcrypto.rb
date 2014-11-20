class DropPgcrypto < ActiveRecord::Migration
  def up
    disable_extension 'pgcrypto'
  end

  def down
    enable_extension 'pgcrypto'
  end
end
