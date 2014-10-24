class AddPostgresCrypto < ActiveRecord::Migration
  def up
    enable_extension 'pgcrypto'
  end

  def down
    disable_extension 'pgcrypto'
  end
end
